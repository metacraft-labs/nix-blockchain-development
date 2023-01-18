{
  description = "nix-blockchain-development";

  nixConfig = {
    extra-substituters = "https://nix-blockchain-development.cachix.org";
    extra-trusted-public-keys = "nix-blockchain-development.cachix.org-1:Ekei3RuW3Se+P/UIo6Q/oAgor/fVhFuuuX5jR8K/cdg=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = github:numtide/flake-utils;
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    {
      overlays.default = import ./overlay.nix;
    }
    // (
      flake-utils.lib.eachDefaultSystem
      (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
            rust-overlay.overlays.default
          ];
        };
      in {
        packages = pkgs.metacraft-labs;
        devShells.default = import ./shell.nix {inherit pkgs;};
      })
    );
}
