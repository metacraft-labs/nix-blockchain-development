{ rust-bin,
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
    version = "unstable-2024-12-04";

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
      rev = "0b787f2e5c8a7f165f905a53f8de44f562d7bbb2";
      hash = "sha256-dOGHnJbW0w4/wPuTtwdN1j/s4OFTzQcai7Vp4HFC58k=";
    };
  };

  rust-toolchain = rust-bin.nightly.latest.default.override {
    targets = ["riscv32i-unknown-none-elf"];
  };
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // (installSourceAndCargo rust-toolchain)
    // rec {
      inherit cargoArtifacts;

      postPatch = ''
        sed -i '/"add"/{n;s/--git/--path/;n;s|".*"|"'$out'/runtime"|}' cli/src/command/new.rs
      '';

      doCheck = false;
    })
