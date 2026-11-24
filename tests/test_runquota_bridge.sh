#!/usr/bin/env bash
# test_runquota_bridge
#
# RQE-M6b: the heavy, finite `nix build` commands of scripts/ci.sh and scripts/ci-all.sh (the devShell
# builds) take a RunQuota lease and run at the granted width instead of assuming every core is theirs.
# A script that lost its bridge still PASSES (nix just runs wider), so the only thing that can notice
# is a test of the bound itself. This is that test.
#
# WHAT IS REAL. A private `runquotad` (small CPU budget, socket in a scratch directory,
# RUNQUOTA_SOCKET + RUNQUOTA_ENDPOINT_SCOPE=private, so no other daemon is touched); the REAL
# `runquota run` with its REAL `nix` adapter; the REAL scripts/runquota-bridge.sh; and the REAL
# scripts/ci.sh and scripts/ci-all.sh, run several sessions at once (a scratch copy of scripts/, so
# --mutate can edit it; the default run copies it unchanged).
#
# WHAT IS STUBBED, AND WHY. `nix` and `nom` are shims first on PATH. The real devShell builds take
# minutes to hours on a shared host and are forbidden here; the unit under test is WHICH commands reach
# the bridge and WHAT ARGUMENTS they arrive with, not what nix does. The shim records argv and
# RUNQUOTA_RUN_WIDTH, then starts one `sleep 0.2537` per build slot nix would use (max-jobs x cores;
# unconstrained is modelled as 8) and waits. The odd duration is one nothing else on a host runs, so
# /proc sampling by exact command line counts the CPU slots in use across all sessions. Peaks are read
# from /proc every 5 ms, never from a log. Not exercised: real nix's treatment of --max-jobs/--cores,
# and distributed builds (`--builders`: Nix's build hook does not count remote jobs against max-jobs).
# NOT BOUNDED: `nix flake check` (it also builds the checks, but the adapter does not recognise it).
#
# WHAT IT ASSERTS
#   1. static: every `build` line in scripts/*.sh carries the bridge;
#   2. dynamic: N sessions running the real scripts at once never exceed the budget AND exceed 1;
#   3. `--max-jobs 1 --cores N` arrives right after `build`; the rest of argv (brace-expanded attrs,
#      --json, -L, ...) is unchanged and in order; `nix flake check` is unchanged (not wrapped);
#   4. stdout and exit status pass through;
#   5. controls: RQ= turns the bridge off, a runquota lacking the verb is not used, no runquota on
#      PATH runs nix unchanged, `nom build` is run as `nix build` under a lease only;
#   6. NEGATIVE CONTROL (--mutate): the bridge is deleted from a copy of the real scripts and the same
#      measurement must then exceed the budget. Prints "MUTATION KILLED" when it does.
#
# Usage: tests/test_runquota_bridge.sh [--mutate]      (or: just test-runquota-bridge [--mutate])
set -uo pipefail

MUTATE=0
[ "${1:-}" = "--mutate" ] && MUTATE=1
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
BUDGET=3
SESSIONS=6
PASS=0; FAILED=0
pass() { PASS=$((PASS + 1)); echo "  ok   $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  FAIL $1"; }
die() { echo "test_runquota_bridge: $*" >&2; exit 2; }
assert_eq() { if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (expected [$2], got [$3])"; fi; }
assert_ge() { if [ "$3" -ge "$2" ]; then pass "$1 ($3 >= $2)"; else fail "$1 (expected >= $2, got $3)"; fi; }
assert_contains() { case "$3" in *"$2"*) pass "$1" ;; *) fail "$1 (missing [$2] in [$3])" ;; esac; }

command -v runquota >/dev/null || die "runquota and runquotad are required on PATH"
command -v runquotad >/dev/null || die "runquota and runquotad are required on PATH"
command -v python3 >/dev/null || die "python3 is required (the /proc sampler)"

# A Unix socket path is limited to ~100 bytes: keep the scratch directory under a short parent.
S="$(mktemp -d "/tmp/rqd.XXXXXX")" || die "mktemp failed"
DAEMON_PID=""
cleanup() {
  [ -n "${RQB_KEEP:-}" ] && { echo "kept $S" >&2; return; }
  # Stop only the daemon this script started, and only if the pid still names it.
  if [ -n "$DAEMON_PID" ] && ps -o args= -p "$DAEMON_PID" 2>/dev/null | grep -q -- "--socket $S/rq.sock"; then
    kill "$DAEMON_PID" 2>/dev/null
  fi
  rm -rf "$S"
}
trap cleanup EXIT

# --- the tree under test: a scratch copy of the real scripts (or of the mutated ones) ------------
TREE="$S/tree"
mkdir -p "$TREE/scripts" || die "mkdir"
cp "$REPO_ROOT"/scripts/*.sh "$TREE/scripts/" || die "copy scripts"
if [ "$MUTATE" = 1 ]; then
  # Delete the bridge from every call site: `"$bridge" run -- $nix build` becomes `$nix build`.
  sed -i -e 's/"\$bridge" run -- //' "$TREE/scripts/ci.sh" "$TREE/scripts/ci-all.sh" || die "mutate"
  grep -q '"\$bridge" run --' "$TREE"/scripts/ci.sh "$TREE"/scripts/ci-all.sh && die "mutation left a bridge behind"
  echo "mutation removed the bridge from scripts/ci.sh and scripts/ci-all.sh"
fi

# --- private daemon ------------------------------------------------------------------------------
export RUNQUOTA_SOCKET="$S/rq.sock" RUNQUOTA_ENDPOINT_SCOPE=private
runquotad --socket "$S/rq.sock" --cpu-milli $((BUDGET * 1000)) --memory-bytes 17179869184 \
  --no-write-stats --estimate-db "$S/est.db" --observation-db "$S/obs.db" --log-file "$S/rqd.log" \
  >"$S/rqd.out" 2>&1 &
DAEMON_PID=$!
for _ in $(seq 100); do runquota status >/dev/null 2>&1 && break; sleep 0.1; done
runquota status >/dev/null 2>&1 || die "the private runquotad did not answer: $(tail -3 "$S/rqd.log" "$S/rqd.out" 2>/dev/null)"

# --- the nix and nom stubs -----------------------------------------------------------------------
mkdir -p "$S/bin"
cat >"$S/bin/nix" <<'EOF2'
#!/usr/bin/env bash
# test shim: record argv and the granted width, answer like nix, hold the slots a build would use.
prog="$(basename "$0")"
{ printf '%s W=%s' "$prog" "${RUNQUOTA_RUN_WIDTH:-unset}"; for a in "$@"; do printf ' [%s]' "$a"; done; printf '\n'; } >>"$NIX_STUB_LOG"
case "${1:-}" in
  build) ;;
  *) exit 0 ;;                                   # `nix flake check`: recorded, no slots
esac
json=0; for a in "$@"; do [ "$a" = "--json" ] && json=1; done
if [ "$json" = 1 ]; then
  echo '[{"drvPath":"/nix/store/stub.drv","outputs":{"out":"/nix/store/stub-out"}}]'
else
  echo "nix-stub-output"
fi
[ -n "${NIX_STUB_FAIL:-}" ] && exit 7
# Slots in use = max-jobs x cores; a nix with neither flag is modelled as using every core (8).
jobs=1; cores=8
while [ $# -gt 0 ]; do
  case "$1" in
    --max-jobs|-j) jobs="$2"; shift ;;
    --cores) cores="$2"; shift ;;
  esac
  shift
done
for _ in $(seq $((jobs * cores))); do sleep 0.2537 & done
wait
EOF2
chmod +x "$S/bin/nix"; cp "$S/bin/nix" "$S/bin/nom"
export PATH="$S/bin:$PATH" NIX_STUB_LOG="$S/stub.log"
unset RUNQUOTA_RUN_WIDTH RQ NIX_STUB_FAIL

cat >"$S/sample.py" <<'EOF2'
import os, sys, time
stop, out = sys.argv[1], sys.argv[2]
peak = 0
while not os.path.exists(stop):
    n = 0
    for p in os.listdir('/proc'):
        if p.isdigit():
            try:
                with open('/proc/%s/cmdline' % p, 'rb') as f:
                    if f.read() == b'sleep\x000.2537\x00':
                        n += 1
            except OSError:
                pass
    peak = max(peak, n)
    time.sleep(0.005)
open(out, 'w').write(str(peak))
EOF2

# stdin is /dev/null so `tty -s` is false and the scripts pick `nix`, whatever terminal runs this test.
run_ci() { bash "$TREE/scripts/ci.sh" </dev/null; }
run_ci_all() { bash "$TREE/scripts/ci-all.sh" </dev/null; }
run_scripts() { run_ci >/dev/null 2>&1 && run_ci_all >/dev/null 2>&1; }

# measure_peak <label>: SESSIONS sessions at once, each running both real scripts; print the peak.
measure_peak() {
  local label="$1" rc_total=0 pids=() sp i p
  rm -f "$S/stop" "$S/peak.$label"; : >"$NIX_STUB_LOG"
  python3 -I "$S/sample.py" "$S/stop" "$S/peak.$label" & sp=$!
  for i in $(seq "$SESSIONS"); do
    run_scripts & pids+=($!)
  done
  for p in "${pids[@]}"; do wait "$p" || rc_total=$((rc_total + 1)); done
  : >"$S/stop"; wait "$sp"
  echo "$rc_total" >"$S/rc.$label"
  cat "$S/peak.$label"
}

if [ "$MUTATE" = 1 ]; then
  peak="$(measure_peak mutated)"
  echo "mutated (bridge deleted from the real scripts): peak concurrent build slots = $peak, budget = $BUDGET"
  if [ "$peak" -gt "$BUDGET" ]; then echo "MUTATION KILLED"; exit 0; fi
  echo "MUTATION SURVIVED: the measurement does not depend on the bridge"; exit 1
fi

# =================================================================================================
echo "== 1. no build is un-bridged (static, over the real scripts) =="
# Every executable line of scripts/*.sh that runs `build` through nix/nom/$nix must carry the bridge.
# `nix flake check` is deliberately not in this set: the adapter does not recognise it.
builds="$(grep -nE '(nix|nom|\$nix|\$\{nix\}) +build( |$)|nix-build' "$REPO_ROOT"/scripts/*.sh | grep -vE ':[0-9]+:[[:space:]]*#' || true)"
unbridged="$(printf '%s\n' "$builds" | grep -v 'runquota-bridge\.sh\|"\$bridge" run -- ' | grep . || true)"
assert_eq "every executable build line in scripts/*.sh carries the bridge" "" "$unbridged"
assert_eq "the two known build sites are the only ones" 2 "$(printf '%s\n' "$builds" | grep -c .)"

echo "== 2. sessions at once, one budget =="
peak="$(measure_peak bridged)"
assert_eq "all $SESSIONS sessions of the real scripts exited 0" 0 "$(cat "$S/rc.bridged")"
assert_ge "the bridge let more than one build slot run at once (a width above one was really granted)" 2 "$peak"
if [ "$peak" -le "$BUDGET" ]; then pass "peak concurrent build slots $peak <= budget $BUDGET"; else fail "peak $peak exceeds budget $BUDGET"; fi
echo "  measured peak $peak of budget $BUDGET across $SESSIONS sessions x 2 scripts"
builds_logged="$(grep -c '^nix W=[^ ]* \[build\]' "$NIX_STUB_LOG")"
assert_eq "every session's two builds reached the stub" $((SESSIONS * 2)) "$builds_logged"
bad="$(grep -E '\[build\]' "$NIX_STUB_LOG" | grep -vE '^nix W=[1-9][0-9]* \[build\] \[--max-jobs\] \[1\] \[--cores\] \[[1-9][0-9]*\] ' || true)"
assert_eq "every build arrives with --max-jobs 1 --cores N right after build" "" "$bad"
mism="$(grep -E '\[build\]' "$NIX_STUB_LOG" | awk '{ split($2,a,"="); match($0,/\[--cores\] \[[0-9]+\]/); w=substr($0,RSTART+11,RLENGTH-12); if (a[2]!=w) print }')"
assert_eq "--cores equals RUNQUOTA_RUN_WIDTH on every line" "" "$mism"

echo "== 3. argv passes through unchanged and in order =="
strip_inserted() { sed -E 's/ \[--max-jobs\] \[1\] \[--cores\] \[[0-9]+\]//; s/ W=[^ ]+//'; }
sys="$(case "$(uname -s).$(uname -m)" in Linux.x86_64) echo x86_64-linux;; Linux.aarch64) echo aarch64-linux;; Darwin.x86_64) echo x86_64-darwin;; Darwin.*) echo aarch64-darwin;; esac)"
: >"$NIX_STUB_LOG"; run_ci >/dev/null 2>&1; cp "$NIX_STUB_LOG" "$S/ci.bridged"
: >"$NIX_STUB_LOG"; RQ='' run_ci >/dev/null 2>&1; cp "$NIX_STUB_LOG" "$S/ci.plain"
assert_eq "ci.sh: bridged argv == unbridged argv minus the adapter's flags (flake check included)" \
  "$(strip_inserted <"$S/ci.plain")" "$(strip_inserted <"$S/ci.bridged")"
assert_contains "ci.sh: the build line is as written" "nix W=unset [build] [--json] [--print-build-logs] [.#devShells.$sys.default]" "$(cat "$S/ci.plain")"
assert_contains "ci.sh: flags land right after build, attrs and flags intact, in order" "[build] [--max-jobs] [1] [--cores] [" "$(cat "$S/ci.bridged")"
assert_contains "ci.sh: the rest of argv follows" "] [--json] [--print-build-logs] [.#devShells.$sys.default]" "$(cat "$S/ci.bridged")"
: >"$NIX_STUB_LOG"; run_ci_all >/dev/null 2>&1; cp "$NIX_STUB_LOG" "$S/all.bridged"
: >"$NIX_STUB_LOG"; RQ='' run_ci_all >/dev/null 2>&1; cp "$NIX_STUB_LOG" "$S/all.plain"
assert_eq "ci-all.sh: bridged argv == unbridged argv minus the adapter's flags" \
  "$(strip_inserted <"$S/all.plain")" "$(strip_inserted <"$S/all.bridged")"
assert_contains "ci-all.sh: the brace-expanded attrs, --json, -L arrive in order after the flags" \
  "] [-L] [--json] [--no-link] [--keep-going] [.#devShells.x86_64-linux.default] [.#devShells.x86_64-darwin.default] [.#devShells.aarch64-darwin.default]" "$(cat "$S/all.bridged")"
assert_eq "ci-all.sh is one bridged build, not three" 1 "$(grep -c '\[build\]' "$S/all.bridged")"
for f in ci.bridged all.bridged; do
  assert_contains "$f: 'nix flake check' is unchanged (not wrapped, no width flags)" "nix W=unset [flake] [check]" "$(cat "$S/$f")"
done
: >"$NIX_STUB_LOG"; "$TREE/scripts/runquota-bridge.sh" run -- nix build --cores 2 .#x >/dev/null
assert_contains "an explicit --cores is respected" "[build] [--max-jobs] [1] [--cores] [2] [.#x]" "$(cat "$NIX_STUB_LOG")"

echo "== 4. stdout and exit status =="
out="$("$TREE/scripts/runquota-bridge.sh" run -- nix build .#x)"
assert_eq "a \$(...) capture sees only the command's own output" "nix-stub-output" "$out"
out="$(run_ci 2>/dev/null)"
assert_eq "ci.sh's stdout is the build's JSON only" '[{"drvPath":"/nix/store/stub.drv","outputs":{"out":"/nix/store/stub-out"}}]' "$out"
NIX_STUB_FAIL=1 "$TREE/scripts/runquota-bridge.sh" run -- nix build .#x >/dev/null; assert_eq "the command's exit status passes through the bridge" 7 "$?"
NIX_STUB_FAIL=1 run_ci >/dev/null 2>&1; assert_eq "a failing build fails ci.sh with the build's status" 7 "$?"
NIX_STUB_FAIL=1 run_ci_all >/dev/null 2>&1; assert_eq "a failing build fails ci-all.sh with the build's status" 7 "$?"
"$TREE/scripts/runquota-bridge.sh" >/dev/null 2>&1; assert_eq "a bad invocation (no verb) is a usage error" 2 "$?"
"$TREE/scripts/runquota-bridge.sh" run nix build >/dev/null 2>&1; assert_eq "a missing -- is a usage error" 2 "$?"

echo "== 5. the escape hatch and its controls =="
: >"$NIX_STUB_LOG"
RQ='' "$TREE/scripts/runquota-bridge.sh" run -- nix build .#x >/dev/null
assert_eq "RQ= runs nix with no lease and no width flag" "nix W=unset [build] [.#x]" "$(cat "$NIX_STUB_LOG")"
peak_off="$(RQ='' measure_peak off)"
assert_ge "RQ= turns the bridge off: the same sessions then exceed the budget" $((BUDGET + 1)) "$peak_off"
: >"$NIX_STUB_LOG"
RQ='env RUNQUOTA_RUN_WIDTH=2' "$TREE/scripts/runquota-bridge.sh" run -- nix build .#x >/dev/null
assert_eq "RQ=<prefix> replaces the prefix (width taken from it)" "nix W=2 [build] [.#x]" "$(cat "$NIX_STUB_LOG")"
# A runquota that predates the verb prints usage and exits 0 -- it must not be used.
mkdir -p "$S/old"; printf '#!/usr/bin/env bash\necho "usage: runquota ..."; exit 0\n' >"$S/old/runquota"; chmod +x "$S/old/runquota"
: >"$NIX_STUB_LOG"
PATH="$S/old:$PATH" "$TREE/scripts/runquota-bridge.sh" run -- nix build .#x >/dev/null
assert_eq "a runquota without the run verb is not used; nix runs unchanged" "nix W=unset [build] [.#x]" "$(cat "$NIX_STUB_LOG")"
# A PATH of symlinks to just the tools the script and the stub use: whole tool directories (e.g. a Nix
# profile's bin/) can also hold `runquota`, which would defeat the control.
mkdir -p "$S/nort"
for t in bash env tr dirname basename seq sleep cat; do ln -sf "$(command -v "$t")" "$S/nort/$t"; done
: >"$NIX_STUB_LOG"
PATH="$S/bin:$S/nort" "$TREE/scripts/runquota-bridge.sh" run -- nix build .#x >/dev/null
assert_eq "with no runquota on PATH nix runs unchanged" "nix W=unset [build] [.#x]" "$(cat "$NIX_STUB_LOG")"
# nom: the adapter does not know it, so under a lease it is run as nix; unleased it stays nom.
: >"$NIX_STUB_LOG"
"$TREE/scripts/runquota-bridge.sh" run -- nom build -L .#x >/dev/null
assert_contains "under a lease nom build runs as nix build with the width flags" "nix W=" "$(cat "$NIX_STUB_LOG")"
assert_contains "... carrying --max-jobs 1 --cores N" "[build] [--max-jobs] [1] [--cores] [" "$(cat "$NIX_STUB_LOG")"
: >"$NIX_STUB_LOG"
RQ='' "$TREE/scripts/runquota-bridge.sh" run -- nom build -L .#x >/dev/null
assert_eq "with RQ= nom stays nom" "nom W=unset [build] [-L] [.#x]" "$(cat "$NIX_STUB_LOG")"

echo
echo "test_runquota_bridge: $PASS passed, $FAILED failed"
[ "$FAILED" = 0 ]
