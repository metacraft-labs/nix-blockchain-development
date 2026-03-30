{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.forc
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Fuel Recorder dev shell"
  '';
}
