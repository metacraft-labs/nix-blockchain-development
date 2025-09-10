{
  lib,
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
      hash = "744b999f0a35b3c86753311c7efb2a0054be21727095cf105af6ee7d3f4d8849";
    in
    fetchurl {
      url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${hash}.zip";
      hash = builtins.convertHash {
        inherit hash;
        toHashFormat = "sri";
        hashAlgo = "sha256";
      };
    };

  commonArgs = rec {
    pname = "risc0";
    version = "3.0.3";

    nativeBuildInputs = [
      autoPatchelfHook
      pkg-config
      openssl
      stdenv.cc.cc.lib
    ];

    src = fetchFromGitHub {
      owner = "risc0";
      repo = "risc0";
      rev = "v${version}";
      hash = "sha256-39vVvvGcWbQOBm8G08GvjpSklMCjcGNq2+UabfU1+gs=";
    };
  };

  rust-toolchain = rustFromToolchainFile {
    dir = commonArgs.src;
    sha256 = "sha256-+9FmLhAOezBZCOziO0Qct1NOrfpjNsXxc/8I0c7BdKE=";
  };
  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // {
    inherit cargoArtifacts;

    # NOTE: leave ability to change comments without modifying the bash code, avoiding unneeded rebuilds
    postPatch = lib.concatStringsSep "\n" [
      # Replace references to the normal installations of `rustup` and `risc0`
      # As per <https://github.com/risc0/risc0/blob/14b5d588dd01cf4f7ba804d8bb0a61264e6ae2c6/rzup/src/env.rs#L213>,
      # used in places like <https://github.com/risc0/risc0/blob/14b5d588dd01cf4f7ba804d8bb0a61264e6ae2c6/rzup/src/components.rs#L139>
      # bash
      ''
        RISC0_PATHBUF='PathBuf::from(r#"'"${risc0-rust}"'"#)'
        sed -i \
            -e '215s|home_dir.join(".risc0")|'"$RISC0_PATHBUF"'|' \
            -e '219s|home_dir.join(".rustup")|'"$RISC0_PATHBUF"'|' \
            ./rzup/src/env.rs
      ''

      # Fix starter template
      # bash
      ''
        sed -i 's|{{ risc0_build }}|path = "'$out'"|' ./risc0/cargo-risczero/templates/rust-starter/methods/Cargo-toml
        sed -i 's|{{ risc0_zkvm }}|path = "'$out'"|' ./risc0/cargo-risczero/templates/rust-starter/host/Cargo-toml
      ''
    ];

    preBuild = ''
      export RECURSION_SRC_PATH="${recursion-zkr}"
      export RUSTFLAGS="$RUSTFLAGS -A dead_code"
    '';

    cargoBuildCommand = "cargo build --release -p risc0-zkvm -p risc0-build -p cargo-risczero --features unstable";

    doCheck = false;
  }
)
