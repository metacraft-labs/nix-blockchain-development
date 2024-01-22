set dotenv-load := true

root-dir := justfile_directory()
result-dir := root-dir / ".result"
gc-roots-dir := result-dir / "gc-roots"
nix := `if tty -s; then echo nom; else echo nix; fi`
cachix-cache-name := `echo ${CACHIX_CACHE:-}`
cachix-deploy-spec-json := ".result/cachix-deploy-spec.json"

os := if os() == "macos" { "darwin" } else { "linux" }
arch := arch()
system: os && "-" && arch

create-result-dirs:
  #!/usr/bin/env bash
  set -euo pipefail
  mkdir -p "{{result-dir}}" "{{gc-roots-dir}}"

build-cachix-deploy-spec:
  {{nix}} build --no-link --json --print-build-logs .#packages.{{system}}.cachix-deploy-bare-metal-spec | jq -r '.[].outputs | to_entries[].value'

push-cachix-deploy-spec cache-name=cachix-cache-name: build-not-cached
  jq -r \
    '.agents | to_entries | map(.value) | .[]' \
    .result/cachix-deploy-spec.json \
  | cachix push {{cache-name}}

deploy-cachix-spec: build-not-cached
  cachix deploy activate .result/cachix-deploy-spec.json --async

bootstrap ssh-host-before config ssh-host-after:
  ./scripts/bootstrap-machine.bash {{ssh-host-before}} {{config}} {{ssh-host-after}}

eval-packages: create-result-dirs
  #!/usr/bin/env bash
  set -euo pipefail

  if [[ -z "${MAX_WORKERS:-}" ]]; then
    available_parallelism="$(nproc)"
    max_workers="$((available_parallelism < 8 ? available_parallelism : 8))"
  else
    max_workers="$MAX_WORKERS"
  fi

  if [ "{{os}}" = "darwin" ]; then
    pages="$(vm_stat | grep 'Pages free:' | tr -s ' ' | cut -d ' ' -f 3 | tr -d '.')"
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
    --flake .#legacyPackages.{{system}}.metacraft-labs

build-not-cached:
  #!/usr/bin/env bash
  set -euo pipefail

  rm -f .result/cachix-deploy-spec.json
  nix_eval_result=$(just eval-packages)

  echo "------------------"
  echo "Nix eval complete."
  echo

  packages=$(echo "$nix_eval_result" | jq -sr '
    map({ name: .attr, isCached, drvPath, out: .outputs.out })
    | sort_by(.name | ascii_downcase)
  ')

  packages_to_build=$(echo "$packages" | jq '. | map(select(.isCached | not))')
  num_packages_to_build=$(echo "$packages_to_build" | jq '. | length')
  num_packages=$(echo "$packages" | jq '. | length')

  echo "* $num_packages packages found:"

  packages_csv=$(echo "$packages" | jq -r '.
    | ["name", "isCached"] as $cols
    | map(. as $row | $cols | map($row[.])) as $rows
    | $cols, $rows[]
    | @tsv
  ')
  packages_csv=$(echo name$'\t'cached$'\n'"$packages_csv" | sed -e 's/\t/\t| /g' | tail -n +2)

  echo "$packages_csv" | column -t -s $'\t'
  echo
  echo "------------------"

  echo "* $((num_packages - num_packages_to_build)) packages cached"
  echo "* $num_packages_to_build packages to build"
  echo "------------------"
  echo

  if [ "$num_packages_to_build" -gt 0 ]; then
    IFS=$'\n' drvs=( $(echo "$packages_to_build" | jq -r '.[] | .drvPath') )
    derivations=( ${drvs[@]/%/^*} )

    (
      set -x
      {{nix}} build --no-link --json -L ${derivations[*]} | jq 'map(.outputs.out)'
    )

    echo "------------------"
    echo "Build complete."
  else
    echo "All packages are cached, skipping build."
  fi

  echo "$packages" | jq '
    {
      agents: map({
        key: .name, value: .out
      }) | from_entries
    }' \
    > .result/cachix-deploy-spec.json
