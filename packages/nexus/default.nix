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
    version = "unstable-2024-12-18";

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
      rev = "315938cfd29d66ddfa7526d793f63b8b114d09e8";
      hash = "sha256-lXptNVcbECefrn67X92feV3l6F9+fWZpeMCQglyBVJA=";
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
