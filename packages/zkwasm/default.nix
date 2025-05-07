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
    version = "1.2-unstable-2025-04-27";

    nativeBuildInputs = [
      clang
      lld
      cmake
    ];

    src = fetchFromGitHub {
      owner = "DelphinusLab";
      repo = "zkWasm";
      rev = "48fc8adc2f045a09e8b919361f8b399ccae25dc4";
      hash = "sha256-usPZxVznmaJoOsUWgqizQJDWtFfGKY5zU1wRbxX/Dj4=";
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
