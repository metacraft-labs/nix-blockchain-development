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
    version = "4.2.0-dev-unstable-2025-05-06";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "fee04caca378c866c1dcc267b27d3ef8ec0cded4";
      hash = "sha256-n6LK5G7bul64uRNYfqtfKc4wSSQ+EXZm22hMhYQSl2E=";
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
