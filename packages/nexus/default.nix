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
    version = "0.3.1-unstable-2025-04-02";

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
      rev = "9524f16bc02202ae586e7c35d160936eef399f7f";
      hash = "sha256-1WxOrw1+K1wXxtlOTyklB7jJOhb8SuIjl8xVc2CHql0=";
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
