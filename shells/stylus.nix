{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    metacraft-labs.foundry
    metacraft-labs.cargo-stylus
  ];
}
