{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    pkgs.rustup
    pkgs.foundry
    metacraft-labs.cargo-stylus
    metacraft-labs.nitro-devnode
  ];
}
