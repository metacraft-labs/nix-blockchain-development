{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.forc
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Fuel Recorder dev shell"
  '';
}
