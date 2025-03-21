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
    version = "unstable-2025-03-11";

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
      rev = "56ab8e5b953de45903ae9dfde498e8413a9c611b";
      hash = "sha256-d5M3U3FtOA/Vuq/nXujhAmo9GOH5QYgLN2/2JmegaY8=";
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
