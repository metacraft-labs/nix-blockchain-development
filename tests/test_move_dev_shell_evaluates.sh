#!/usr/bin/env bash
# The `move` dev shell evaluates on macOS and carries a working `sui`.
#
# `shells/move.nix` lists `self'.packages.sui`. That package was defined only
# on Linux, so on a Mac the shell failed at evaluation with
# "attribute 'sui' missing", and codetracer-move-recorder, whose dev shell
# takes `inputsFrom` this one, lost its whole environment (Rust, Nim and all),
# not only `sui`. On macOS `sui` is now the official release binary of the
# same version Linux builds from source (packages/sui/prebuilt-darwin.nix).
#
# Asserted:
#   1. `devShells.<system>.move` evaluates for both aarch64-darwin and
#      x86_64-darwin, whichever system this host is.
#   2. On a Darwin host, inside `nix develop .#move`, `sui --version` reports
#      the version packages/sui/version.nix pins, and `sui move test` offers
#      `--trace`: the recorder needs a build with the `tracing` feature.
#
# The Linux systems are not evaluated here: the Linux `sui` is built from
# source with crane, whose evaluation imports from a derivation, so evaluating
# a Linux shell from a Mac stops on "Cannot build '…-source.drv' … Required
# system: 'x86_64-linux'" unless a Linux builder is configured. Linux CI
# evaluates and builds those shells.
#
#   bash tests/test_move_dev_shell_evaluates.sh
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }
LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT

for system in aarch64-darwin x86_64-darwin; do
  nix eval --no-write-lock-file --raw "$REPO#devShells.$system.move.drvPath" >/dev/null 2>"$LOG" \
    || fail "devShells.$system.move does not evaluate: $(grep 'error: ' "$LOG" | tail -1 | sed 's/^ *//')"
done

host="$(nix eval --impure --raw --expr builtins.currentSystem)"
case "$host" in
  *-darwin)
    want="$(nix eval --raw --file "$REPO/packages/sui/version.nix")"
    # The shell hook prints a banner on stdout, so keep only sui's own line.
    out="$(nix develop --no-write-lock-file "$REPO#move" -c sui --version 2>"$LOG")" \
      || fail "sui --version failed in the move shell: $(tail -3 "$LOG")"
    got="$(printf '%s\n' "$out" | grep '^sui ' || true)"
    case "$got" in
      "sui $want-"*) ;;
      *) fail "the move shell's sui reports '${got:-$out}', expected version $want" ;;
    esac
    # Captured rather than piped into `grep -q`, which would close the pipe
    # early and, under pipefail, fail the check on nix's SIGPIPE.
    help="$(nix develop --no-write-lock-file "$REPO#move" -c sui move test --help 2>"$LOG")" \
      || fail "sui move test --help failed in the move shell: $(tail -3 "$LOG")"
    grep -q -- '--trace' <<<"$help" \
      || fail "the move shell's sui does not offer 'sui move test --trace' (built without tracing?)"
    ;;
  *) echo "note: host is $host; the in-shell sui checks run on a Darwin host only" ;;
esac

echo "PASS: devShells.{aarch64,x86_64}-darwin.move evaluate; sui ${want:-?} with --trace on $host"
