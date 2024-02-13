set dotenv-load := true

root-dir := justfile_directory()
result-dir := root-dir / ".result"
gc-roots-dir := result-dir / "gc-roots"
nix := `if tty -s; then echo nom; else echo nix; fi`
cachix-cache-name := `echo ${CACHIX_CACHE:-}`

os := if os() == "macos" { "darwin" } else { "linux" }
arch := arch()
system:= arch + "-" + os

default:
  @just --list

get-system:
  @echo {{ system }}

create-result-dirs:
  #!/usr/bin/env bash
  set -euo pipefail
  mkdir -p "{{result-dir}}" "{{gc-roots-dir}}"

eval-packages eval-system=system: create-result-dirs
  #!/usr/bin/env bash
  set -euo pipefail

  if [[ -z "${MAX_WORKERS:-}" ]]; then
    available_parallelism="$(nproc)"
    max_workers="$((available_parallelism < 8 ? available_parallelism : 8))"
  else
    max_workers="$MAX_WORKERS"
  fi

  if [ "{{os}}" = "darwin" ]; then
    free_pages="$(vm_stat | grep 'Pages free:' | tr -s ' ' | cut -d ' ' -f 3 | tr -d '.')"
    inactive_pages="$(vm_stat | grep 'Pages inactive:' | tr -s ' ' | cut -d ' ' -f 3 | tr -d '.')"
    pages="$((free_pages + inactive_pages))"
    page_size="$(pagesize)"
    max_memory_mb="${MAX_MEMORY:-$(echo $((($pages * $page_size) / 1024 / 1024 )))}"
  else
    free="$(cat /proc/meminfo | grep MemFree | tr -s ' ' | cut -d ' ' -f 2)"
    cached="$(cat /proc/meminfo | grep Cached | grep -v SwapCached | tr -s ' ' | cut -d ' ' -f 2)"
    buffers="$(cat /proc/meminfo | grep Buffers | tr -s ' ' | cut -d ' ' -f 2)"
    shmem="$(cat /proc/meminfo | grep Shmem: | tr -s ' ' | cut -d ' ' -f 2)"

    max_memory_mb="${MAX_MEMORY:-$(echo $((($free + $cached + $buffers + $shmem) / 1024 )))}"

  fi

  set -x

  nix-eval-jobs \
    --check-cache-status \
    --gc-roots-dir "{{gc-roots-dir}}" \
    --workers "$max_workers" \
    --max-memory-size "$max_memory_mb" \
    --flake .#legacyPackages.{{eval-system}}.metacraft-labs

generate-matrix: create-result-dirs
  #!/usr/bin/env bash
  set -euo pipefail

  rm -f .result/cachix-deploy-spec.json
  nix_eval_result=$(just eval-packages x86_64-linux 2> /dev/null)$(just eval-packages x86_64-darwin 2> /dev/null)$(just eval-packages aarch64-darwin 2> /dev/null)

  packages=$(echo "$nix_eval_result" | jq -csr '
    map({
      package: .attr,
      isCached,
      allowedToFail: false,
      system: .system,
      attrPath: (.system + "." + .attr),
      out: (
        .outputs.out
        | ( "https://mcl-blockchain-packages.cachix.org/" + match("^\/nix\/store\/([^-]+)-").captures[0].string + ".narinfo")
      ),
      os: (
        if (.system == "x86_64-linux")
        then "ubuntu-latest"
        else "macos-14"
        end
      )
    })
      | sort_by(.package | ascii_downcase )
  ')

  table_inputs=$(echo "$packages" | jq -c 'group_by(.package) |
    map({package: .[0].package, "x86_64-linux": "🚫 not supported", "x86_64-darwin": "🚫 not supported", "aarch64-darwin": "🚫 not supported"}
      + (map({(.system): (if .isCached then ("[✅ cached](" + .out + ")") else ("[building](" + .out + ")") end)}) | add)) | sort_by(.package)')

  packages_to_build=$(echo "$packages" | jq -c '. | map(select(.isCached | not))')
  if (( $(echo "$packages_to_build" | jq '. | length') > 0 )); then
    matrix='{"include":'"$packages_to_build"'}'
  else
    matrix='{}'
  fi
  echo "$matrix" > matrix.json
  echo "matrix=$matrix" >> "$GITHUB_OUTPUT"

  table=$(echo "$table_inputs" | commentablefmt )
  {
    echo "Thanks for your Pull Request!"
    echo
    echo "Below you will find a summary of the cachix status of each package, for each supported platform."
    echo
    echo "$table"
    echo
  } > comment.md
