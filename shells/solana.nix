{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    # Solana CLI and Anchor are available in nixpkgs but may fail to build
    # on some platforms. The recorder uses mollusk-svm/litesvm as cargo
    # dependencies, so the CLI is not strictly required for recording.
    # TODO: Add solana-cli when build issues are resolved
    # TODO: Add cargo-build-sbf for building SBF programs
    rustc
    cargo
    pkg-config
    openssl
    capnproto
  ];

  shellHook = ''
    echo "CodeTracer Solana Recorder dev shell"
    echo "Note: solana CLI not yet available; mollusk/litesvm come via cargo deps"
  '';
}
