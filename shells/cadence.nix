{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    rustc
    cargo
    pkg-config
    openssl
    capnproto
    go
  ];

  shellHook = ''
    echo "CodeTracer Cadence/Flow Recorder dev shell"
  '';
}
