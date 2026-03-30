{
  rustFromToolchainFile,
  craneLib,
  fetchFromGitHub,
  pkg-config,
  openssl,
  ...
}:
let
  commonArgs = rec {
    pname = "miden";
    version = "0.22.0";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "0xPolygonMiden";
      repo = "miden-vm";
      rev = "v${version}";
      hash = "sha256-hF/sRTCFwefnzg0mclgWlMPKwAIPRftHnsEc7qoOqOI=";
    };
  };

  rust-toolchain = rustFromToolchainFile {
    dir = commonArgs.src;
    sha256 = "sha256-SJwZ8g0zF2WrKDVmHrVG3pD2RGoQeo24MEXnNx5FyuI=";
  };

  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // rec {
    inherit cargoArtifacts;

    # Builds the miden-vm binary (CLI) — requires 'executable' feature
    cargoBuildCommand = "cargo build --release -p miden-vm --features executable";

    doCheck = false;
  }
)
