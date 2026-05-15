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
  ];

  shellHook = ''
    echo "CodeTracer Cairo Recorder dev shell"
  '';
}
