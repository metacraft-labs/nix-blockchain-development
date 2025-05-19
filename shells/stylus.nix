{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    pkgs.rustup
    metacraft-labs.foundry
    metacraft-labs.cargo-stylus
    metacraft-labs.nitro-devnode
  ];
}
