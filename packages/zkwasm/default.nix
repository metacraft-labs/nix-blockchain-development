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
    version = "unstable-2024-10-19";

    nativeBuildInputs = [
      clang
      lld
      cmake
    ];

    src = fetchFromGitHub {
      owner = "DelphinusLab";
      repo = "zkWasm";
      rev = "f5acf8c58c32ac8c6426298be69958a6bea2b89a";
      hash = "sha256-3+ptucjczxmA0oeeokxdVRRSdJLuoRjX31hMk5+FlZM=";
      fetchSubmodules = true;
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
