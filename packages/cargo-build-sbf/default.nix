{
  rustFromToolchainFile,
  craneLib,
  fetchFromGitHub,
  pkg-config,
  openssl,
  perl,
  ...
}:
let
  commonArgs = rec {
    pname = "cargo-build-sbf";
    version = "3.1.11";

    nativeBuildInputs = [
      pkg-config
      openssl
      perl # needed by openssl-sys build script
    ];

    src = fetchFromGitHub {
      owner = "anza-xyz";
      repo = "agave";
      rev = "v${version}";
      hash = "sha256-gTN+SzfOz3uPq/nDGsiBz3Y4GnV0hm+1qV7Q1Gwcb2g=";
    };

    # These workspace members lack src/ directories, which breaks crane's
    # dummy-source replacement. Create minimal stubs instead of removing them
    # from Cargo.toml (which would invalidate the vendored Cargo.lock).
    postPatch = ''
      for d in client-test keygen programs/bpf-loader-tests \
               programs/compute-budget-bench programs/ed25519-tests \
               programs/zk-elgamal-proof-tests rpc-test dev-bins programs/sbf; do
        mkdir -p "$d/src"
        touch "$d/src/lib.rs"
      done
    '';
    cargoCheckCommand = "cargo check --release -p solana-cargo-build-sbf";
    cargoBuildCommand = "cargo build --release -p solana-cargo-build-sbf";
    cargoTestCommand = "true";
  };

  rust-toolchain = rustFromToolchainFile {
    dir = commonArgs.src;
    sha256 = "sha256-X/4ZBHO3iW0fOenQ3foEvscgAPJYl2abspaBThDOukI=";
  };

  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // rec {
    inherit cargoArtifacts;

    doCheck = false;
  }
)
