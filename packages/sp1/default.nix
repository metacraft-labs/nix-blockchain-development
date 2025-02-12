{
  sp1-rust,
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
    version = "unstable-2025-02-09";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "6a921fb256ce949c57bae7c83c49f8aaa6c35f3c";
      hash = "sha256-OCwl4M5ln3onl70e/otznsuTcAd/AIE02stMLL4JTWI=";
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
