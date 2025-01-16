{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    cmake
    pkg-config
    openssl
    metacraft-labs.nexus
  ];
}
