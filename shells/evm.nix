{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    solc
    foundry
  ];
}
