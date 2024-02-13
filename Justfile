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

eval-packages eval-system=system:
  #!/usr/bin/env bash
  set -euo pipefail
  source "{{root-dir}}/scripts/nix-eval-jobs.sh"
  nix_eval_jobs legacyPackages.{{eval-system}}.metacraft-labs

generate-matrix:
  "{{root-dir}}/scripts/ci-matrix.sh"
