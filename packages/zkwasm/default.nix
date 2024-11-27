{ clang,
  lld,
  cmake,
  rust-bin,
  craneLib-stable,
  fetchFromGitHub,
}:
let
  craneLib = craneLib-stable.overrideToolchain rust-bin.nightly."2023-06-01".default;

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

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // rec {
      inherit cargoArtifacts;

      doCheck = false;
    })
