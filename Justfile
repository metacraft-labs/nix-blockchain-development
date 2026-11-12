set dotenv-load := true

root-dir := justfile_directory()
result-dir := root-dir / ".result"
gc-roots-dir := result-dir / "gc-roots"
nix := `if tty -s; then echo nom; else echo nix; fi`
attic-cache-name := `echo ${ATTIC_CACHE:-}`

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

# Entering the `ci` dev shell from another git repository must write nothing
# there. Runs `nix develop`, so it is not part of the in-shell recipes.
test-dev-shell:
    bash tests/test_dev_shell_writes_nothing_elsewhere.sh

# The `move` dev shell evaluates on both Darwin systems and aarch64-linux and,
# on those hosts, carries a `sui` of the pinned version built with tracing.
# Runs `nix develop`.
test-move-dev-shell:
    bash tests/test_move_dev_shell_evaluates.sh

# No tracked file sets a zero `min-free` / `max-free`, which turns off Nix's
# automatic garbage collection on a shared host.
test-nix-gc-floor:
    bash tests/test_no_nix_gc_override.sh

# Evaluate every exported zkVM shell and enforce the supported-system matrix.
test-zkvm-dev-shells:
    bash tests/test_zkvm_dev_shells_evaluate.sh

# The `move` shell's `sui` replays (with --trace) a current mainnet
# transaction; fails once packages/sui/version.nix falls behind mainnet's
# protocol version. Needs network access. Runs `nix develop`.
test-sui-mainnet-replay:
    bash tests/test_sui_replays_current_mainnet.sh

# The `miden` and `fuel` shells are exported exactly where their SDK package
# exists (Linux), and the recorder shells exported on Darwin evaluate.
test-recorder-dev-shells:
    bash tests/test_recorder_dev_shells_evaluate.sh
