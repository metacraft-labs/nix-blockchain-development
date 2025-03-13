{
  lib,
  rustPlatform,
  craneLib,
  fetchFromGitHub,
  pkg-config,
  zlib,
  gcc,
  openssl,
  cvc4,
  cbc,
  binutils,
  gnum4,
}:
let
  commonArgs = rec {
    pname = "circ";
    version = "0-unstable-2025-02-13";

    src = fetchFromGitHub {
      owner = "circify";
      repo = "circ";
      rev = "e3ce78496727654795295ea88282cdfb3adc255b";
      hash = "sha256-v7K4xSOLcYWGlJJBjxakgnUPJPxBYLqre9PLKTZ+vRw=";
    };

    nativeBuildInputs = [
      rustPlatform.bindgenHook
      zlib
      gcc
      openssl
      cvc4
      (cbc.overrideAttrs (
        finalAttrs: previousAttrs: {
          configureFlags = [
            "-C"
            "--enable-static"
            "CXXFLAGS=-std=c++14"
          ];
        }
      ))
      binutils
      gnum4
    ];
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
  commonArgs
  // rec {
    inherit cargoArtifacts;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mv target/release/examples/circ $out/bin

      runHook postInstall
    '';

    buildNoDefaultFeatures = true;
    buildFeatures = [
      "c"
      "zok"
      "datalog"
      "smt"
      "lp"
      "aby"
      "kahip"
      "kahypar"
      "r1cs"
      "poly"
      "spartan"
      "bellman"
    ];

    meta = with lib; {
      description = "Cir)cuit (C)ompiler. Compiling high-level languages to circuits for SMT, zero-knowledge proofs, and more";
      homepage = "https://github.com/circify/circ";
      license = with licenses; [
        asl20
        mit
      ];
      maintainers = with maintainers; [ ];
      platforms = with platforms; linux ++ darwin;
    };
  }
)
