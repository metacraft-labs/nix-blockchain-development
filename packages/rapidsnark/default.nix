{
  lib,
  stdenv,
  ffiasm,
  zqfield-bn254,
  nlohmann_json,
  gmp,
  libsodium,
  fetchFromGitHub,
  pkg-config,
}:
let
  ffiasm-c = "${ffiasm}/lib/node_modules/ffiasm/c";
in
stdenv.mkDerivation rec {
  pname = "rapidsnark";
  version = "2023-03-08";

  src = fetchFromGitHub {
    owner = "PetarKirov";
    repo = "rapidsnark";
    rev = "fix/prover/macos-build";
    hash = "sha256-nLKy1zTeiIIZFFnEGhO3yFysQrJqe1VZOAMaBNxPMqY=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    nlohmann_json
    gmp
    libsodium
  ] ++ ffiasm.passthru.openmp;

  buildPhase = ''
    mkdir -p $out/bin
    c++ \
      -I{${ffiasm-c},${zqfield-bn254}/lib} \
      ./src/{main_prover,binfile_utils,zkey_utils,wtns_utils,logger}.cpp \
      ${ffiasm-c}/{alt_bn128,misc,naf,splitparstr}.cpp \
      ${zqfield-bn254}/lib/{fq,fr}.{cpp,o} \
      $(pkg-config --cflags --libs libsodium gmp nlohmann_json) \
      -std=c++17 -pthread -O3 -fopenmp \
      -o $out/bin/prover
  '';

  meta = {
    homepage = "https://github.com/iden3/rapidsnark";
    platforms = with lib.platforms; linux ++ darwin;
  };
}
