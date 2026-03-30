{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.sui
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Move Recorder dev shell"
  '';
}
