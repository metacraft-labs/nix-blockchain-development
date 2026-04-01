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
    echo "CodeTracer PolkaVM Recorder dev shell"
  '';
}
