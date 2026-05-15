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
    zstd # required by libcodetracer_trace_writer
  ];

  shellHook = ''
    echo "CodeTracer Solana Recorder dev shell"
  '';
}
