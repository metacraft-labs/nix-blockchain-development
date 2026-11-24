#!/usr/bin/env bash
# runquota-bridge.sh -- put a heavy, finite build command under a RunQuota lease when one is available.
#
#   runquota-bridge.sh run [FLAGS] -- CMD [ARG...]    CMD takes a width flag; `runquota run` adds it
#
# It `exec`s either `runquota run FLAGS -- CMD` or plain `CMD`, so the command's output and exit
# status are untouched (a `$(...)` capture still sees only what CMD printed) and, where RunQuota is
# absent, the command runs exactly as it did before.
#
# WHY. Several checkouts and agent sessions share each host, and every `nix build` assumed every core
# was its own (`max-jobs` x `cores` from nix.conf), so together they oversubscribed it. Under a lease
# the build takes its slots from the host's shared budget, waits its turn, and runs at the granted
# width: the `nix` adapter of `runquota run` inserts `--max-jobs 1 --cores N` right after `build`
# (it respects an explicit --max-jobs/-j or --cores). The idiom is documented in
# reprobuild/docs/user-guide/runquota-in-justfiles.md; this file is that idiom for this repository's
# CI scripts (scripts/ci.sh, scripts/ci-all.sh), which are plain scripts run outside a dev shell.
#
# CONTROL. RQ unset     auto: bridge when the installed `runquota` has the `run` verb
#          RQ=          (empty) off: run CMD directly
#          RQ="PREFIX"  any other value replaces `runquota run FLAGS --`, e.g.
#                       RQ="runquota run --width 2 --" pins a width
#
# PROBE THE VERB, NOT THE BINARY. A `runquota` that predates `run` prints its usage and exits 0 rather
# than rejecting the word, so a bridged build would "pass" without running anything. `--adapter list`
# prints a table starting `adapters` only on a build that has the verb, and takes no lease.
#
# nom. The CI scripts' `$nix` is `nom` on an interactive terminal. The adapter
# recognises `nix ... build` and `nix-build`, not `nom`, so a leased `nom build` would hold slots and
# still run unbounded. While a lease is taken, `nom build ...` is therefore run as `nix build ...`
# (nom only adds a progress display). `RQ=` keeps nom.
#
# NOT COVERED. `nix flake check` also builds the checks, but the adapter does not recognise it, so it
# is not wrapped and is not bounded. scripts/nix-eval-jobs.sh is eval-only and sizes its own workers.
# Wrap the command that does the work: the lease is held for the command's whole life.
set -uo pipefail

_rq_run_available() {
  command -v runquota >/dev/null 2>&1 || return 1
  # Captured, not piped into `grep -q`: under pipefail grep's early exit would SIGPIPE the writer and
  # read as "verb absent".
  local out
  out="$(runquota run --adapter list 2>/dev/null </dev/null)" || true
  case "$out" in adapters*|*$'\n'adapters*) return 0 ;; esac
  return 1
}

verb="${1:-}"
if [ "$verb" != run ]; then
  echo "usage: runquota-bridge.sh run [FLAGS] -- CMD [ARG...]" >&2
  exit 2
fi
shift

flags=()
while [ $# -gt 0 ] && [ "$1" != "--" ]; do flags+=("$1"); shift; done
[ "${1:-}" = "--" ] || { echo "runquota-bridge.sh: missing '--' before the command" >&2; exit 2; }
shift
[ $# -gt 0 ] || { echo "runquota-bridge.sh: missing command" >&2; exit 2; }

# Under a lease, `nom build` becomes `nix build` so the adapter can bound it (see "nom" above).
_rq_unnom() {
  if [ "$1" = nom ] && [ "${2:-}" = build ]; then
    set -- nix "${@:2}"
  fi
  cmd=("$@")
}

if [ "${RQ+set}" = set ]; then
  if [ -n "$RQ" ]; then
    _rq_unnom "$@"
    # shellcheck disable=SC2086  # the prefix is a command line on purpose
    exec $RQ "${cmd[@]}"
  fi
  exec "$@"
fi
if _rq_run_available; then
  _rq_unnom "$@"
  exec runquota run ${flags[@]+"${flags[@]}"} -- "${cmd[@]}"
fi
exec "$@"
