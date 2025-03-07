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
    version = "unstable-2025-03-06";

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
      rev = "d9b3b3760cebe8ef7215cf0432fcb3c323a6f624";
      hash = "sha256-rOKyAo+pN5M8Un+wqkymAydjKHaZQ+FYjbldavql8zY=";
    };
  };

  rust-toolchain = rust-bin.nightly."2025-01-02".default.override {
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
      sed -i '/"add"/{n;s/--git/--path/;n;s|".*"|"'$out'/runtime"|}' cli/src/command/host.rs
    '';

    doCheck = false;
  }
)
