{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    metacraft-labs.risc0
  ];
}
