{
  description = "nix-blockchain-development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
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
          ];
        };
      in {
        packages = pkgs.metacraft-labs;
        devShells.default = import ./shell.nix {inherit pkgs;};
      })
    );
}
