#!/usr/bin/env bash

set -euo pipefail

error() {
    echo "Error: " "$@" >&2
    exit 1
}

nix="$(if tty -s; then echo nom; else echo nix; fi)"

get_platform() {
  case "$(uname -s).$(uname -m)" in
    Linux.x86_64)
        system=x86_64-linux
        ;;
    Linux.i?86)
        system=i686-linux
        ;;
    Linux.aarch64)
        system=aarch64-linux
        ;;
    Linux.armv6l_linux)
        system=armv6l-linux
        ;;
    Linux.armv7l_linux)
        system=armv7l-linux
        ;;
    Darwin.x86_64)
        system=x86_64-darwin
        ;;
    Darwin.arm64|Darwin.aarch64)
        system=aarch64-darwin
        ;;
    *) error "sorry, there is no binary distribution of Nix for your platform";;
  esac

  echo "$system"
}

system="$(get_platform)"

set -x
nix flake check
$nix build --json --print-build-logs ".#devShells.$system.default"
