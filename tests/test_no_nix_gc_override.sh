#!/usr/bin/env bash
# No tracked file turns off Nix's automatic garbage collection.
#
# `--option min-free 0`, `max-free = 0` in NIX_CONFIG and the like remove the
# host's free-space floor. A trusted user's daemon connection accepts the
# override, and no nix.conf setting can refuse it, so a test or recipe that
# passes it lets its builds fill a shared CI host's disk (nixos-ci-bare-004,
# 2026-10-28). A run that needs more space than the floor allows must wait for
# the collector or fail, which reports the shortage, rather than disable it.
# Policy: metacraft-dev-guidelines agents/shared-agent-instructions.md,
# "Shared Build Hosts".
#
# Asserted: no tracked line outside a comment sets `min-free` or `max-free` to 0
# in any spelling Nix accepts (`--option NAME 0`, the per-setting flag
# `--NAME 0`, `NAME = 0` in nix.conf or NIX_CONFIG, `"NAME" = 0;` in a Nix
# attribute set, `NAME=0`, and a unit suffix such as `0G`).
# As the positive control, the detector matches each of those spellings and
# none of the non-zero floors.
#
#   bash tests/test_no_nix_gc_override.sh
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }

# The setting name is split so this file does not match its own pattern.
setting='(min|max)''-free'
pattern="${setting}[\"']?([[:space:]]*=[[:space:]]*|[[:space:]]+)[\"']?0+([^0-9.]|\$)"
detects() { printf '%s\n' "$1" | grep -Eq -- "$pattern"; }

for spelling in \
  "nix build --option min""-free 0 ." \
  "nix_args=(--option min""-free '0' --impure)" \
  "NIX_CONFIG=\"max""-free = 0\" nix develop" \
  "nix develop --min""-free 0 --impure" \
  "nix.settings.\"max""-free\" = 0;" \
  "min""-free=0" \
  "max""-free 0G"; do
  detects "$spelling" || fail "detector misses: $spelling"
done
for floor in "min""-free = 1073741824" "min""-free 10G" "max""-free = 0.5" "min""-free = 1"; do
  ! detects "$floor" || fail "detector flags a non-zero floor: $floor"
done

# git grep exits 1 when nothing matches. Any higher status is an error, which
# must fail the test rather than read as a clean tree.
rc=0
matches="$(git -C "$REPO" grep -nIE -- "$pattern")" || rc=$?
[ "$rc" -le 1 ] || fail "git grep exited $rc"
# Comment-only lines (`#` in shell, Nix and Justfile) run nothing, so prose that
# names the setting is not a hit.
if [ -n "$matches" ] && hits="$(printf '%s\n' "$matches" | grep -Ev "^[^:]+:[0-9]+:[[:space:]]*#")"; then
  printf '%s\n' "$hits" >&2
  fail "the lines above turn off Nix's automatic garbage collection"
fi
echo "PASS: no tracked file disables Nix's automatic garbage collection"
