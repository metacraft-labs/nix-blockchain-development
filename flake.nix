{
  description = "nix-blockchain-development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
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
            rust-overlay.overlay
          ];
        };
      in {
        packages = pkgs.metacraft-labs;
        devShells.default = import ./shell.nix {inherit pkgs;};
      })
    );
}
