{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.miden
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Miden Recorder dev shell"
  '';
}
