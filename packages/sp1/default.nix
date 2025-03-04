{
  sp1-rust,
  craneLib-nightly,
  fetchFromGitHub,
  fetchGitHubFile,
  installSourceAndCargo,
  pkg-config,
  openssl,
  ...
}:
let
  commonArgs = rec {
    pname = "sp1";
    version = "unstable-2025-03-04";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "b6eb0482541fe8816230229574a4fb199c5c01a1";
      hash = "sha256-XdBQztyPJC6E9jXSRfO/lBGTFssDIEsU6ey8YoKmOGE=";
      fetchSubmodules = true;
    };
  };

  rust-toolchain = sp1-rust;
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    cargoBuildCommand = "cargo build --release -p sp1-cli";

    doCheck = false;
  }
)
