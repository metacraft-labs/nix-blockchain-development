{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    metacraft-labs.zkwasm
  ];
}
