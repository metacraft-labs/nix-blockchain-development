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
    version = "0.3.6-unstable-2026-01-06";

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
      rev = "f2ad12652c39dc516a116447a53f8557f64a7f7d";
      hash = "sha256-Xdpf1JYomVoUy0uemZoKkZudffyOy9ItowrBj19k5qQ=";
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
