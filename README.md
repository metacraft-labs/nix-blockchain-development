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
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
      flake-utils.url = github:numtide/flake-utils;
      mcl-blockchain.url = "github:metacraft-labs/nix-blockchain-development"; # <new>
      mcl-blockchain.inputs.nixpkgs.follows = "nixpkgs";                       # <new>
      mcl-blockchain.inputs.flake-utils.follows = "flake-utils";               # <new>
    };

    outputs = {
      self,
      nixpkgs,
      flake-utils,
      mcl-blockchain, # <new>
    }:
      flake-utils.lib.simpleFlake {
        inherit self nixpkgs;
        name = "solana-hello-world";
        shell = ./shell.nix;
        preOverlays = [mcl-blockchain.overlays.default]; # <new>
      };
  }
  ```

* `shell.nix`:

  ```nix
  {pkgs}:
  with pkgs;
    mkShell {
      packages = [
        metacraft-labs.solana # <new>
      ];
    }
  ```
