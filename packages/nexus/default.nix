{
  fenix,
  rustFromToolchainFile,
  craneLib,
  fetchFromGitHub,
  installSourceAndCargo,
  pkg-config,
  openssl,
  cmake,
  ...
}:
let
  commonArgs = rec {
    pname = "Nexus-zkVM";
    version = "0.3.1-unstable-2025-03-28";

    nativeBuildInputs = [
      pkg-config
      openssl
      cmake
    ];

    # https://crane.dev/faq/no-cargo-lock.html
    cargoLock = ./Cargo.lock;

    src = fetchFromGitHub {
      owner = "nexus-xyz";
      repo = "nexus-zkvm";
      rev = "5d2e394f6b39dd25a3f67c79bb750c5c0931e8b0";
      hash = "sha256-pdrxImfz/QaLj9d4iEAolI8laJaaqleFzHwVd/dOmQU=";
    };
  };

  rust-toolchain =
    let
      toolchain = {
        dir = commonArgs.src;
        sha256 = "sha256-J0fzDFBqvXT2dqbDdQ71yt2/IKTq4YvQs6QCSkmSdKY=";
      };
    in
    fenix.combine [
      (rustFromToolchainFile toolchain)
      (fenix.targets.riscv32i-unknown-none-elf.fromToolchainFile toolchain)
    ];
  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    postPatch = ''
      sed -i '/"add"/{n;s/--git/--path/;n;s|".*"|"'$out'/runtime"|}' cli/src/command/host.rs
    '';

    doCheck = false;
  }
)
