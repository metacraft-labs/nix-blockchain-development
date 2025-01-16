{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    metacraft-labs.sp1
  ];
}
