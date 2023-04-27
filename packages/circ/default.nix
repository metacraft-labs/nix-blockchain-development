{
  lib,
  rustPlatform,
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
rustPlatform.buildRustPackage rec {
  pname = "circ";
  version = "unstable-2023-03-20";

  src = fetchFromGitHub {
    owner = "circify";
    repo = "circ";
    rev = "18990d079e988db842b83591528dc9739c3dbf9f";
    hash = "sha256-/GVqlBacGdN6Cp0dxaHi4G13zeggdm75PFrftjStZTg=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "bellman-0.13.1" = "sha256-e++6s64xJNagsBIBUfZ1RoXyN8taMdEfwcDPWKmp17Y=";
    };
  };

  nativeBuildInputs = [
    zlib
    gcc
    openssl
    cvc4
    cbc
    binutils
    gnum4
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv target/*/release/examples/circ $out/bin

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
    license = with licenses; [asl20 mit];
    maintainers = with maintainers; [];
    platforms = with platforms; linux ++ darwin;
  };
}
