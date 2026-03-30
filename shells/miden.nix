{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.miden
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Miden Recorder dev shell"
  '';
}
