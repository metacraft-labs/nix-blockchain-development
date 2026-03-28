{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    # Miden VM crates are pulled as cargo dependencies
    # The miden CLI, midenc compiler, and cargo-miden would need
    # to be built from source via crane or downloaded as binaries
    # TODO: Add miden-vm, midenc, cargo-miden packages
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Miden Recorder dev shell"
    echo "Note: miden CLI and midenc not yet packaged; miden-* crates available via cargo"
  '';
}
