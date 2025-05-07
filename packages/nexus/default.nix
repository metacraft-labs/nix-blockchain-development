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
    version = "0.3.1-unstable-2025-04-17";

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
      rev = "a0c85c3d85ab0a7677f95f0b60ed2b68d6cbd119";
      hash = "sha256-rpsX540fORHEfGwg7J6x/W8Af9Rs1CgKWDx3Y+ZFgQs=";
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
