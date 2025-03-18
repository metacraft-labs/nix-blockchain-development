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
    version = "unstable-2025-03-10";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "342422d99bd9b68aee718b70a53446dfe7ee3f3a";
      hash = "sha256-z3PbRb3Oj2+GCXnnM3EBVP9+oZU7C6o3mwRpjN2z7gU=";
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
