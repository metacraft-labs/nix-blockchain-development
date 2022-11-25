# nix-blockchain-development

A Nix flake offering blockchain development tools

## Packages

This repo is provided as a Nix Flake. The packages defined here can be consumed
via one of the flake output categories:

* `overlays.default` (which you can e.g. apply on top of Nixpkgs)
  * All packages are placed inside the `metacraft-labs` namespace
  * For example: `metacraft-labs.solana`
* `packages.${arch}.${pkg}` - suitable for use with `nix shell`

## Usage examples

### Imperative (ad hoc) with `nix shell`

```sh
# Replace solana with the package you want to use:
nix shell github:metacraft-labs/nix-blockchain-development#solana
```

### Declarative with Nix Flakes dev shell

* `flake.nix`:

  ```nix
  {
    # <after>:
    # Opt into `nix-blockchain-development`'s substituter (binary cache).
    # `nixConfig` settings are not transitive so every user of a flake with a
    # custom binary cache must manually include its `nixConfig` settings for
    # substituters and trusted public keys:
    nixConfig = {
      extra-substituters = "https://nix-blockchain-development.cachix.org";
      extra-trusted-public-keys = "nix-blockchain-development.cachix.org-1:Ekei3RuW3Se+P/UIo6Q/oAgor/fVhFuuuX5jR8K/cdg=";
    };

    inputs = {
      # <before>:
      # nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
      # flake-utils.url = github:numtide/flake-utils;

      # <after>:
      # To ensure all packages from mcl-blockchain will be fetched from its
      # binary cache we need to ensure that we use exact same commit hash of the
      # inputs below. If we didn't, we may either:
      # * end up with multiple copies of the same package from nixpkgs
      # * be unable to use the binary cache, since the packages there where
      #   using different versions of their dependencies from nixpkgs
      mcl-blockchain.url = "github:metacraft-labs/nix-blockchain-development";
      nixpkgs.follows = "mcl-blockchain/nixpkgs";
      flake-utils.follows = "mcl-blockchain/flake-utils";
    };

    outputs = {
      self,
      nixpkgs,
      flake-utils,
      mcl-blockchain, # <after>
    }:
      flake-utils.lib.simpleFlake {
        inherit self nixpkgs;
        name = "solana-hello-world";
        shell = ./shell.nix;
        preOverlays = [mcl-blockchain.overlays.default]; # <after>
      };
  }
  ```

* `shell.nix`:

  ```nix
  {pkgs}:
  with pkgs;
    mkShell {
      packages = [
        metacraft-labs.solana # <after>
      ];
    }
  ```

### Packages

## Circ
## Circom
## Cosmos-Theta-Testnet
## Cargo-Build-BPF
## Elrond-Go
⚡ Elrond-GO: The official implementation of the Elrond protocol, written in golang.
## Elrond-Proxy-Go
🐙 Elrond Proxy: The official implementation of the web proxy for the Elrond Network. An intermediary that abstracts away the complexity of Elrond sharding, through a friendly HTTP API.
## Erdpy
Elrond python Command Line Tools and SDK for interacting with the Elrond Network (in general) and Smart Contracts (in particular).
## Solana-BPF-Tools
## Solana-Full-SDK
## Solana-Rust-Artifacts
## Wasmd
