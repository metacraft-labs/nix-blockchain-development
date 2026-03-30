{
  craneLib,
  fetchFromGitHub,
  pkg-config,
  openssl,
  perl,
  llvmPackages,
  ...
}:
let
  commonArgs = rec {
    pname = "forc";
    version = "0.70.3";

    nativeBuildInputs = [
      pkg-config
      openssl
      perl # needed by openssl-sys build script
      llvmPackages.libclang # needed by librocksdb-sys (bindgen)
    ];

    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

    src = fetchFromGitHub {
      owner = "FuelLabs";
      repo = "sway";
      rev = "v${version}";
      hash = "sha256-phfm+wDMiVsx1m7Wh1/6YzTbGQ3pXSO5D8WTVAYe1TU=";
    };

    # The sway workspace has fuel-core-relayer which fails to compile due to
    # missing ethers crate. Scope all cargo commands to just the forc crate
    # and skip test compilation to avoid pulling in unrelated workspace members.
    cargoCheckCommand = "cargo check --release -p forc";
    cargoBuildCommand = "cargo build --release -p forc";
    cargoTestCommand = "true"; # skip test build during buildDepsOnly

    doCheck = false;
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
  commonArgs
  // {
    inherit cargoArtifacts;
  }
)
