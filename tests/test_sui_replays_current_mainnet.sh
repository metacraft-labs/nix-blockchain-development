#!/usr/bin/env bash
# The `move` dev shell's `sui` replays a current Sui mainnet transaction.
#
# codetracer-move-recorder traces mainnet through `sui replay --trace`, run
# with the `sui` of this repo's `move` shell. A `sui` binary refuses to
# execute under a protocol version newer than the newest it knows: replay
# then panics with "Network protocol version is ProtocolVersion(N), but the
# maximum supported version by the binary is M". The pinned 1.68.1 knew
# protocol 118 while mainnet ran 139, so no current transaction could be
# replayed or traced. Mainnet raises its protocol version every few weeks,
# so this check also tells when packages/sui/version.nix has fallen behind:
# bump it to the newest `mainnet-v*` release (see packages/sui/version.nix).
#
# Asserted, against live mainnet (the network is the subject of the check,
# so it is not mocked; an unreachable endpoint is a failure, not a skip):
#   1. Inside `nix develop .#move`, `sui replay --trace` of the newest
#      successful programmable transaction on mainnet exits 0 and writes a
#      non-empty `trace.json.zst`.
#   2. The replayed effects agree with the chain: status `Success`, the
#      same computation cost, storage cost, storage rebate and
#      non-refundable storage fee as the on-chain gas summary, the same
#      lamport version, and, for every object the replay writes, the same
#      output digest as mainnet recorded for that object.
#
# Runs on any host whose `move` shell can be built. On Linux that builds
# `sui` from source with crane.
#
#   bash tests/test_sui_replays_current_mainnet.sh
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAPHQL="https://graphql.mainnet.sui.io/graphql"
FULLNODE="https://fullnode.mainnet.sui.io:443"
fail() { echo "FAIL: $*" >&2; exit 1; }
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

graphql() {
  curl -fsS --max-time 60 -X POST "$GRAPHQL" \
    -H 'content-type: application/json' --data "$1"
}

# The newest successful programmable transaction (not a system transaction,
# so the trace contains user Move calls) whose object changes fit on one
# page, with its on-chain effects: gas summary, lamport version, and the
# output digest of every changed object. The chosen transaction's effects
# are written to $WORK/expected.json for the comparison below.
query='{"query":"{ epoch { protocolConfigs { protocolVersion } } transactions(last: 20, filter: {kind: PROGRAMMABLE_TX}) { nodes { digest effects { status lamportVersion gasEffects { gasSummary { computationCost storageCost storageRebate nonRefundableStorageFee } } objectChanges(first: 50) { pageInfo { hasNextPage } nodes { address outputState { digest } } } } } } }"}'
graphql "$query" >"$WORK/chain.json" \
  || fail "cannot query Sui mainnet GraphQL at $GRAPHQL"
read -r protocol digest < <(
  python3 - "$WORK/chain.json" "$WORK/expected.json" <<'EOF'
import json, sys
data = json.load(open(sys.argv[1]))["data"]
ok = [n for n in data["transactions"]["nodes"]
      if n["effects"]["status"] == "SUCCESS"
      and not n["effects"]["objectChanges"]["pageInfo"]["hasNextPage"]]
if not ok:
    sys.exit("no successful programmable transaction among the newest 20")
n = ok[-1]
fx = n["effects"]
json.dump({
    "gas": fx["gasEffects"]["gasSummary"],
    "lamport": str(fx["lamportVersion"]),
    "outputs": {c["address"]: (c["outputState"] or {}).get("digest")
                for c in fx["objectChanges"]["nodes"]},
}, open(sys.argv[2], "w"))
print(data["epoch"]["protocolConfigs"]["protocolVersion"], n["digest"])
EOF
) || fail "unexpected GraphQL response: $(head -c 400 "$WORK/chain.json")"

# A throwaway client config, so the check neither reads nor writes ~/.sui.
cat >"$WORK/client.yaml" <<EOF
---
keystore:
  File: $WORK/sui.keystore
envs:
  - alias: mainnet
    rpc: "$FULLNODE"
    ws: ~
    basic_auth: ~
active_env: mainnet
active_address: ~
EOF
echo '[]' >"$WORK/sui.keystore"

if ! nix develop --no-write-lock-file "$REPO#move" -c \
    sui replay --client.config "$WORK/client.yaml" -d "$digest" \
    --trace -o "$WORK/out" --quiet >"$WORK/replay.log" 2>&1; then
  why="$(grep -m1 'maximum supported version' "$WORK/replay.log" || tail -5 "$WORK/replay.log")"
  fail "sui replay of mainnet transaction $digest (protocol $protocol) failed: $why"
fi

dir="$WORK/out/$digest"
[ -s "$dir/trace.json.zst" ] || fail "sui replay --trace wrote no trace for $digest"
[ -s "$dir/transaction_effects.json" ] || fail "sui replay wrote no effects for $digest"

python3 - "$dir/transaction_effects.json" "$WORK/expected.json" <<'EOF' \
  || fail "replayed effects of $digest differ from mainnet's"
import json, sys
fx = json.load(open(sys.argv[1]))
fx = next(iter(fx.values()))  # {"V2": {...}}
want = json.load(open(sys.argv[2]))
errors = []
if fx["status"] != "Success":
    errors.append(f"status {fx['status']}")
gas = {k: str(v) for k, v in fx["gas_used"].items()}
if gas != {k: str(v) for k, v in want["gas"].items()}:
    errors.append(f"gas {gas}, chain {want['gas']}")
if str(fx["lamport_version"]) != want["lamport"]:
    errors.append(f"lamport version {fx['lamport_version']}, chain {want['lamport']}")
# Every object the replay writes must carry the digest mainnet recorded for
# it; the gas coin alone guarantees at least one.
writes = {addr: change["output_state"]["ObjectWrite"][0]
          for addr, change in fx["changed_objects"]
          if "ObjectWrite" in (change["output_state"] or {})}
if not writes:
    errors.append("replay wrote no objects")
for addr, d in writes.items():
    if want["outputs"].get(addr) != d:
        errors.append(f"object {addr} digest {d}, chain {want['outputs'].get(addr)}")
if errors:
    sys.exit("replay differs from chain: " + "; ".join(errors))
EOF

version="$(nix eval --raw --file "$REPO/packages/sui/version.nix")"
echo "PASS: sui $version replayed mainnet transaction $digest (protocol $protocol) with --trace; effects match the chain"
