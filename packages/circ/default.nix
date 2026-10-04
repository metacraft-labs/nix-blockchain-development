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
    version = "unstable-2024-04-17";

    src = fetchFromGitHub {
      owner = "circify";
      repo = "circ";
      rev = "7f6d0a00fe1298bc02d98c34db191afc4b46c943";
      hash = "sha256-pYG6IYGHv4DwizCdVZbOS4DUxwNtwQVcPU66fDxTxg0=";
    };

    # circ's crates set `#![deny(warnings)]`, so every lint a newer rustc adds
    # (e.g. mismatched_lifetime_syntaxes) fails the build. Lints are not
    # correctness checks for a packaged release: report them, do not fail.
    RUSTFLAGS = "--cap-lints warn";

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
