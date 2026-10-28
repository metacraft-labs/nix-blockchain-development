#!/usr/bin/env bash
# Exercise the real flake and pinned packages, without mocks, foreign machines,
# or package builds. The export matrix is explicit: Nexus on both Linux hosts;
# Jolt, zkMIPS, SP1 and RISC Zero on x86_64 Linux (their guest toolchains are
# x86_64 Linux archives); no zkVM shell on Darwin; no broken zkWasm shell.
#
# Every exported shell must evaluate to a derivation, and contain the actual
# SDK package from self'.packages. This catches both the missing self' argument
# and shells that silently drop the SDK. Unexpected exports also fail.
#
# Crane/fenix read rust-toolchain files from fixed-output source derivations
# during evaluation. Realize those exact sources with the host's native pinned
# fetcher first: fixed-output source paths/hashes are architecture independent,
# so this permits Linux evaluation on a Mac without executing a Linux builder.
# Output equality is asserted; the target shell and SDK derivation graphs stay
# unchanged, and the native fetch produces the same hash-verified source bytes.
# Fenix also imports fixed-output Rust channel manifests. An unavailable foreign
# manifest fetch is prepared natively from its real derivation metadata, then
# the entire original assertion is evaluated again. Only flat, hash-pinned Rust
# channel fetches qualify; repeated prerequisites and all other errors fail.
# Success always requires every original assertion and drvPath evaluation.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
prepared_manifests=" "
nix_args=(--option min-free 0 --option builders '' --no-write-lock-file --impure)

for name in jolt nexus zkm sp1 risc0; do
  echo "Realizing pinned $name source on this host"
  nix build "${nix_args[@]}" --max-jobs 1 --cores 2 --no-link --expr "
    let
      flake = builtins.getFlake \"$REPO\";
      source = flake.packages.x86_64-linux.\"$name\".src;
      pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
      nativeSource = pkgs.fetchFromGitHub ({
        inherit (source) owner repo rev;
        hash = source.outputHash;
      } // pkgs.lib.optionalAttrs (source ? fetchSubmodules) {
        inherit (source) fetchSubmodules;
      });
    in assert source.outPath == nativeSource.outPath; nativeSource
  "
done

for system in x86_64-linux aarch64-linux aarch64-darwin x86_64-darwin; do
  echo "Checking zkVM shells for $system"
  while ! nix eval "${nix_args[@]}" --json --expr "
    let
      flake = builtins.getFlake \"$REPO\";
      shells = flake.devShells.\"$system\";
      packages = flake.packages.\"$system\";
      names = [ \"jolt\" \"nexus\" \"zkm\" \"zkwasm\" \"sp1\" \"risc0\" ];
      expected = {
        x86_64-linux = [ \"jolt\" \"nexus\" \"zkm\" \"sp1\" \"risc0\" ];
        aarch64-linux = [ \"nexus\" ];
        aarch64-darwin = [ ];
        x86_64-darwin = [ ];
      }.\"$system\";
    in builtins.map (name:
      assert builtins.hasAttr name shells == builtins.elem name expected;
      if builtins.elem name expected then
        assert builtins.elem packages.\${name} shells.\${name}.nativeBuildInputs;
        shells.\${name}.drvPath
      else null
    ) names
  " >"$SCRATCH/result" 2>"$SCRATCH/eval-error"; do
    # This is prerequisite preparation, never an accepted test outcome.
    # Derive its identity from Nix's failed real evaluation, not a test pin.
    if ! grep -q 'Reason: required system or feature not available' "$SCRATCH/eval-error"; then
      cat "$SCRATCH/eval-error" >&2
      exit 1
    fi
    manifest_drv="$(sed -n "s/.*error: Cannot build '\(\/nix\/store\/[^']*-channel-rust-[^']*\.toml\.drv\)'.*/\1/p" "$SCRATCH/eval-error")"
    if [ -z "$manifest_drv" ]; then
      cat "$SCRATCH/eval-error" >&2
      exit 1
    fi
    echo "Preparing pinned Rust channel manifest $manifest_drv on this host"
    case "$prepared_manifests" in
      *" $manifest_drv "*) echo "FAIL: manifest still unavailable after native preparation" >&2; exit 1 ;;
    esac
    nix derivation show "$manifest_drv" >"$SCRATCH/manifest.json"
    nix build "${nix_args[@]}" --max-jobs 1 --cores 2 --no-link --expr "
      let
        flake = builtins.getFlake \"$REPO\";
        pkgs = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
        metadata = builtins.fromJSON (builtins.readFile \"$SCRATCH/manifest.json\");
        derivations = if metadata ? derivations then metadata.derivations else metadata;
        drv = builtins.head (builtins.attrValues derivations);
        env = drv.env;
        nativeManifest = pkgs.fetchurl {
          inherit (env) name;
          url = env.urls;
          hash = env.outputHash;
        };
      in
        assert builtins.length (builtins.attrValues derivations) == 1;
        assert env.outputHashMode == \"flat\";
        assert env.outputHash != \"\";
        assert env.outputHashAlgo == \"sha256\";
        assert builtins.match \"channel-rust-.*[.]toml\" env.name != null;
        assert builtins.match \"https://static[.]rust-lang[.]org/dist/([0-9]{4}-[0-9]{2}-[0-9]{2}/)?channel-rust-[^ ]*[.]toml\" env.urls != null;
        assert env.out == nativeManifest.outPath;
        nativeManifest
    "
    prepared_manifests="$prepared_manifests$manifest_drv "
  done
  cat "$SCRATCH/result"
done
echo "PASS: zkVM shell export, SDK inclusion and evaluation contract"
