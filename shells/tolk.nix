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
    echo "CodeTracer TON/Tolk Recorder dev shell"
  '';
}
