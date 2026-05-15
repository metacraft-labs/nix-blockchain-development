{ pkgs, self', ... }:
with pkgs;
mkShell {
  packages = [
    self'.packages.circom
    rustc
    cargo
    pkg-config
    openssl
    capnproto
    zstd # required by libcodetracer_trace_writer
    # C++ witness generator toolchain (Circom M6)
    gcc
    gnumake
    nlohmann_json
    gmp
    nodejs_20
  ];

  shellHook = ''
    echo "CodeTracer Circom Recorder dev shell"
  '';
}
