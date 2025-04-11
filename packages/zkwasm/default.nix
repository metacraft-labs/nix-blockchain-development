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
    version = "1.2-unstable-2025-04-10";

    nativeBuildInputs = [
      clang
      lld
      cmake
    ];

    src = fetchFromGitHub {
      owner = "DelphinusLab";
      repo = "zkWasm";
      rev = "6dba6dbb7816208de1d08ce67963094c4aa7684a";
      hash = "sha256-D3DnU12MbDdOfai0525FT7ENf2AcEKQKQyeX0nbnLz0=";
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
