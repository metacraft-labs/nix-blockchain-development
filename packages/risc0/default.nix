{
  risc0-rust,
  rust-bin,
  craneLib-nightly,
  fetchurl,
  fetchFromGitHub,
  fetchGitHubFile,
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
      hash' = "4c67e5fe48c6db03df9518911067685542fecf0a54d5c6e3efd16e943c62a2cf";
    in
    fetchurl rec {
      url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${hash'}.zip";
      hash = "sha256-TGfl/kjG2wPflRiREGdoVUL+zwpU1cbj79FulDxios8=";
    };

  commonArgs = rec {
    pname = "risc0";
    version = "unstable-2025-02-12";

    nativeBuildInputs = [
      autoPatchelfHook
      pkg-config
      openssl
      stdenv.cc.cc.lib
    ];

    src = fetchFromGitHub {
      owner = "risc0";
      repo = "risc0";
      rev = "87a82961b99ff8d98b99825425f6d77557b8d362";
      hash = "sha256-stl7s7FGy35NvWlPRweFhOSHq5U9Ov5fuzBg3KVx+uY=";
    };
  };

  rust-toolchain = rust-bin.fromRustupToolchainFile (fetchGitHubFile {
    inherit (commonArgs.src) owner repo rev;
    file = "rust-toolchain.toml";
    hash = "sha256-n7Jr8rkovVQ98/KNvSg9EG9JZmKWD7DTaXTbpDJKA0Q=";
  });
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
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
