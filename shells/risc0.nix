{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.risc0
  ];
}
