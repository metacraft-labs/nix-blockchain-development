{
  rustFromToolchainFile,
  craneLib,
  fetchFromGitHub,
  clang,
  lld,
  cmake,
  ...
}:
let
  commonArgs = rec {
    pname = "zkWasm";
    version = "explorer-integration-5.0-unstable-2025-07-22";

    nativeBuildInputs = [
      clang
      lld
      cmake
    ];

    src = fetchFromGitHub {
      owner = "DelphinusLab";
      repo = "zkWasm";
      rev = "1fb46ec774388ed012b33f17e11b8c226d7f7f6a";
      hash = "sha256-VLRbAZv1J/B1PkcSjG92WWb97q1K+bsLmsaqZNC7jck=";
      fetchSubmodules = true;
    };

    meta = {
      broken = true;
    };
  };

  rust-toolchain = rustFromToolchainFile {
    dir = commonArgs.src;
    sha256 = "sha256-+LaR+muOMguIl6Cz3UdLspvwgyG8s5t1lcNnQyyJOgA=";
  };

  crane = craneLib.overrideToolchain rust-toolchain;

  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // rec {
    inherit cargoArtifacts;

    doCheck = false;
  }
)
