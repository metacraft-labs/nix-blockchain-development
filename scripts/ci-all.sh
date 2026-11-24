#!/usr/bin/env bash

set -euo pipefail

nix="$(if tty -s; then echo nom; else echo nix; fi)"

bridge="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/runquota-bridge.sh"

set -x
nix flake check
"$bridge" run -- $nix build -L --json --no-link --keep-going \
  .#devShells.{x86_64-linux,{x86_64,aarch64}-darwin}.default
