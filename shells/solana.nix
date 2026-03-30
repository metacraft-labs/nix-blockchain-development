{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.cargo-build-sbf
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Solana Recorder dev shell"
  '';
}
