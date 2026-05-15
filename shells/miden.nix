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
    zstd # required by libcodetracer_trace_writer
  ];

  shellHook = ''
    echo "CodeTracer Miden Recorder dev shell"
  '';
}
