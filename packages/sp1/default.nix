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
    version = "unstable-2024-12-07";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    src = fetchFromGitHub {
      owner = "succinctlabs";
      repo = "sp1";
      rev = "aa5d95360403878c947d1e72b84d7f24cc5ce228";
      hash = "sha256-cF9VXS56h3QTXUwHW2xcfUruNTcw2xAoUVX/rv7Kkw8=";
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
