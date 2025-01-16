{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    pkg-config
    openssl
    metacraft-labs.jolt
  ];
}
