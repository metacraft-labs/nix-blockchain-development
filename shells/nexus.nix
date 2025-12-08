{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    cmake
    pkg-config
    openssl
    self'.packages.nexus
  ];
}
