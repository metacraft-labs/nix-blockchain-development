{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.forc
    rustc
    cargo
    pkg-config
    openssl
    capnproto
    zstd # required by libcodetracer_trace_writer
  ];

  shellHook = ''
    echo "CodeTracer Fuel Recorder dev shell"
  '';
}
