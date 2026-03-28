{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    # Sui CLI needs to be built from source with 'tracing' feature
    # TODO: Add sui CLI package (built with tracing Cargo feature)
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Move Recorder dev shell"
    echo "Note: sui CLI not yet packaged; move-trace-format available as git dep"
  '';
}
