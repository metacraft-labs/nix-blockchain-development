{ rust-bin,
  craneLib-nightly,
  fetchFromGitHub,
  fetchurl,
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
    // rec {
      inherit cargoArtifacts;

      postInstall = ''
        cp -r /build/source/. $out

        # Add cargo (and similar) commands to bin output, so
        # nix shell [flake path]#jolt
        # gives you everything needed to create and work with a jolt-powered
        # projects.
        ln -s "${rust-toolchain}"/bin/* $out/bin/
      '';

      doCheck = false;
    })
