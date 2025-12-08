{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    pkg-config
    openssl
    self'.packages.jolt
  ];
}
