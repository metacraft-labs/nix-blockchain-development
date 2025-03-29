{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  craneLib,
  fetchFromGitHub,
}:
let
  commonArgs = rec {
    pname = "circom";
    version = "2.2.2";

    buildInputs = [ ] ++ (lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ]);
    nativeBuildInputs = [
      rustPlatform.bindgenHook
    ];

    src = fetchFromGitHub {
      owner = "iden3";
      repo = "circom";
      rev = "v${version}";
      hash = "sha256-BSInX4owuamRWnlKL1yJJOyzRIiE55TIzCk2TdX7aOQ=";
    };
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
  commonArgs
  // rec {
    inherit cargoArtifacts;

    doCheck = false;
  }
)
