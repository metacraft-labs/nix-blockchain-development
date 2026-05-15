{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.sui
    rustc
    cargo
    pkg-config
    openssl
    capnproto
    zstd # required by libcodetracer_trace_writer
  ];

  shellHook = ''
    echo "CodeTracer Move Recorder dev shell"
  '';
}
