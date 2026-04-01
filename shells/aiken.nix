{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Aiken Recorder dev shell"
  '';
}
