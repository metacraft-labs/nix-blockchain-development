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
    version = "2.1.5";

    buildInputs = [ ] ++ (lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ]);
    nativeBuildInputs = [
      rustPlatform.bindgenHook
    ];

    src = fetchFromGitHub {
      owner = "iden3";
      repo = "circom";
      rev = "v${version}";
      hash = "sha256-enZr1fkiUxDDDzajsd/CTV7DN//9xP64IyKLQSaJqXk=";
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
