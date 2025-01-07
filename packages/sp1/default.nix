{ sp1-rust,
  craneLib-nightly,
  fetchFromGitHub,
  installSourceAndCargo,
  pkg-config,
  openssl,
  ...
}:
let
  commonArgs = rec {
    pname = "sp1";
    version = "unstable-2024-12-23";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "bfb0c6d8e045b5f40422b9c06cb0e9ee21b3c19c";
      hash = "sha256-gPSjsN0ixoP240ovGfahqRPOsuHFlXwfiVu48KrM4Xs=";
      fetchSubmodules = true;
    };
  };

  rust-toolchain = sp1-rust;
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // (installSourceAndCargo rust-toolchain)
    // rec {
      inherit cargoArtifacts;

      cargoBuildCommand = "cargo build --release -p sp1-cli";

      doCheck = false;
    })
