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
    version = "4.1.3-unstable-2025-03-21";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "b6afca9d4aecc566fd11a939ef36050299151d35";
      hash = "sha256-OJLsoDFpVpzs6C16NnFxNuEP/G8tIg0TTNow61+xBy8=";
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
