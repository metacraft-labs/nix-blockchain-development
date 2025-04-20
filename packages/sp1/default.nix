{
  sp1-rust,
  craneLib,
  fetchFromGitHub,
  installSourceAndCargo,
  pkg-config,
  openssl,
  ...
}:
let
  commonArgs = rec {
    pname = "sp1";
    version = "4.2.0-unstable-2025-04-17";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "51e3964b479953e866dc87bd472bf3525a3bcf2d";
      hash = "sha256-17cMdfdeNgdxdFJB161yL/qFNu1gnV/i8anVTHJXQBo=";
      fetchSubmodules = true;
    };
  };

  rust-toolchain = sp1-rust;
  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    cargoBuildCommand = "cargo build --release -p sp1-cli";

    doCheck = false;
  }
)
