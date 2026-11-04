#!/usr/bin/env bash
# The `miden` and `fuel` dev shells are exported only where their SDK exists.
#
# `shells/miden.nix` and `shells/fuel.nix` list `self'.packages.miden` and
# `self'.packages.forc`. Both packages are defined only on Linux
# (packages/all-packages.nix), yet the shells were exported on every system, so
# on a Mac they failed at evaluation with "attribute 'miden' missing" /
# "attribute 'forc' missing". codetracer-miden-recorder and
# codetracer-fuel-recorder take these shells through `inputsFrom`, so their own
# dev shells inherited the failure and their macOS CI legs could not start.
#
# The contract, the same one test_zkvm_dev_shells_evaluate.sh enforces for the
# zkVM shells: a shell is exported exactly where its SDK package is, so a
# consumer can ask `devShells.<system> ? miden` instead of discovering the gap
# at evaluation. Asserted for all four systems, whatever host this runs on:
#   1. `miden` and `fuel` are exported on Linux and absent on Darwin.
#   2. The SDK package is present exactly where the shell is, so the two cannot
#      drift apart again.
#   3. On the Darwin systems, the recorder shells that are exported at all
#      (`move`, `polkavm`, `cairo`, `leo`, `circom-recorder`) evaluate to a
#      derivation. Linux shells are not evaluated: their crane/fenix packages
#      import from derivations, which needs a Linux builder (see
#      test_zkvm_dev_shells_evaluate.sh); builders are disabled here so the test
#      never dispatches work to another machine, and the export checks above
#      force only attribute names.
#
#   bash tests/test_recorder_dev_shells_evaluate.sh
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }
LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT
nix_args=(--no-write-lock-file --impure --option builders '')

for system in x86_64-linux aarch64-linux aarch64-darwin x86_64-darwin; do
  echo "Checking recorder shell exports for $system"
  case "$system" in
    *-linux) want=true ;;
    *) want=false ;;
  esac
  nix eval "${nix_args[@]}" --json --expr "
    let
      flake = builtins.getFlake \"$REPO\";
      shells = flake.devShells.\"$system\";
      packages = flake.packages.\"$system\";
      sdk = { miden = \"miden\"; fuel = \"forc\"; };
      want = $want;
      yn = b: if b then \"exported\" else \"absent\";
    in builtins.mapAttrs (shell: package:
      assert (builtins.hasAttr shell shells == want)
        || throw \"devShells.$system.\${shell} is \${yn (builtins.hasAttr shell shells)}, want \${yn want}\";
      assert (builtins.hasAttr package packages == want)
        || throw \"packages.$system.\${package} is \${yn (builtins.hasAttr package packages)}, want \${yn want}\";
      true
    ) sdk
  " >/dev/null 2>"$LOG" || fail "$system: $(grep 'error: ' "$LOG" | tail -1 | sed 's/^ *//')"
done

for system in aarch64-darwin x86_64-darwin; do
  for shell in move polkavm cairo leo circom-recorder; do
    echo "Evaluating devShells.$system.$shell"
    nix eval "${nix_args[@]}" --raw "$REPO#devShells.$system.$shell.drvPath" >/dev/null 2>"$LOG" \
      || fail "devShells.$system.$shell does not evaluate: $(grep 'error: ' "$LOG" | tail -1 | sed 's/^ *//')"
  done
done
echo "PASS: recorder shells are exported where their SDK exists, and the Darwin ones evaluate"
