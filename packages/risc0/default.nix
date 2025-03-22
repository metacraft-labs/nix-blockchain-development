{
  risc0-rust,
  rustFromToolchainFile,
  craneLib,
  fetchurl,
  fetchFromGitHub,
  installSourceAndCargo,
  autoPatchelfHook,
  pkg-config,
  openssl,
  stdenv,
  ...
}:
let
  # Value from "SHA256_HASH" constant here:
  # https://github.com/risc0/risc0/blob/main/risc0/circuit/recursion/build.rs
  recursion-zkr =
    let
      hash' = "1b80b77894fbd489262e327478d02e83262c4bf189b0873fda3f0c85cdbfc8d1";
    in
    fetchurl rec {
      url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${hash'}.zip";
      hash = "sha256-G4C3eJT71IkmLjJ0eNAugyYsS/GJsIc/2j8Mhc2/yNE=";
    };

  commonArgs = rec {
    pname = "risc0";
    version = "2.0.0-rc.3-unstable-2025-03-20";

    nativeBuildInputs = [
      autoPatchelfHook
      pkg-config
      openssl
      stdenv.cc.cc.lib
    ];

    src = fetchFromGitHub {
      owner = "risc0";
      repo = "risc0";
      rev = "58f20bbc8346557c901a8e277fd687eac3003fff";
      hash = "sha256-Q22+rj3ZyDQAO8Sq9x+kp6Tavhy6knwbb1L+T6/dZH4=";
    };
  };

  rust-toolchain = rustFromToolchainFile {
    dir = commonArgs.src;
    sha256 = "sha256-s1RPtyvDGJaX/BisLT+ifVfuhDT1nZkZ1NcK8sbwELM=";
  };
  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    postPatch = ''
      # Replace usages of `Command::new("rustup")` with the correct value
      # which should be used
      sed -i '27d;28iPathBuf::from(r"${risc0-rust}")' rzup/src/paths.rs
      # Fix starter template
      sed -i 's|{{ risc0_build }}|path = "'$out'"|' risc0/cargo-risczero/templates/rust-starter/methods/Cargo-toml
      sed -i 's|{{ risc0_zkvm }}|path = "'$out'"|' risc0/cargo-risczero/templates/rust-starter/host/Cargo-toml
    '';

    preBuild = ''
      export RECURSION_SRC_PATH="${recursion-zkr}" RUSTFLAGS="$RUSTFLAGS -A dead_code"
    '';

    cargoBuildCommand = "cargo build --release -p risc0-zkvm -p risc0-build -p cargo-risczero";

    doCheck = false;
  }
)
