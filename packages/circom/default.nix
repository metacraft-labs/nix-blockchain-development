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
    version = "2.2.3";

    buildInputs = [ ];
    nativeBuildInputs = [
      rustPlatform.bindgenHook
    ];

    src = fetchFromGitHub {
      owner = "iden3";
      repo = "circom";
      rev = "v${version}";
      hash = "sha256-om9rLaQAimbBQx3kl+OlRpewqYcEEu0MiudaFfSDI2A=";
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
