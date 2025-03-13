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
    version = "0.3.1-unstable-2025-03-11";

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
