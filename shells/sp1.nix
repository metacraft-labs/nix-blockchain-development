{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.sp1
  ];
}
