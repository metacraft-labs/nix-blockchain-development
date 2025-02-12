{
  rust-bin,
  craneLib-nightly,
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
    version = "unstable-2025-01-08";

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
      rev = "f594536f6fede8ceaf5d8c017a6f6fa2fbea3475";
      hash = "sha256-7jBZB/PAIsFSTrZOHX+0N7zM7/skI7yMsnOJCkXDV1o=";
    };
  };

  rust-toolchain = rust-bin.nightly.latest.default.override {
    targets = [ "riscv32i-unknown-none-elf" ];
  };
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    postPatch = ''
      sed -i '/"add"/{n;s/--git/--path/;n;s|".*"|"'$out'/runtime"|}' cli/src/command/new.rs
    '';

    doCheck = false;
  }
)
