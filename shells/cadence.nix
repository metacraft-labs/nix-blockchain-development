{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    rustc
    cargo
    pkg-config
    openssl
    capnproto
    zstd # required by libcodetracer_trace_writer
    go
  ];

  shellHook = ''
    echo "CodeTracer Cadence/Flow Recorder dev shell"
  '';
}
