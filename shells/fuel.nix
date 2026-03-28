{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    # forc compiler and fuel-core need to be built from source
    # TODO: Add forc, fuel-core packages
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Fuel Recorder dev shell"
    echo "Note: forc and fuel-core not yet packaged"
  '';
}
