{pkgs}:
with pkgs; let
  inherit (metacraft-labs) circom_runtime ffiasm zqfield-default;
in
  stdenv.mkDerivation rec {
    pname = "rapidsnark";
    version = "2023-03-08";
    src = fetchFromGitHub {
      owner = "iden3";
      repo = "rapidsnark";
      rev = "8b254247fd34b523c79ec1b582a4402343bc8094";
      hash = "sha256-IqQ/Rc1l5MzFeoIjxRz9Oj6uzElAe6hEbhE97+3Ct4c=";
    };

    nativeBuildInputs = [gtest nodejs nasm];

    buildInputs = [ffiasm nlohmann_json circom_runtime gmp libsodium];

    buildPhase = ''
      runHook preBuild
      mkdir $out
      mkdir build

      echo buildProver
        cd build
          g++ -I. -I../src -I${ffiasm}/lib/node_modules/ffiasm/c -I${zqfield-default}/lib -I${nlohmann_json}/include -I${libsodium.dev}/include ../src/main_prover.cpp ../src/binfile_utils.cpp ../src/zkey_utils.cpp ../src/wtns_utils.cpp ../src/logger.cpp ${ffiasm}/lib/node_modules/ffiasm/c/misc.cpp ${ffiasm}/lib/node_modules/ffiasm/c/naf.cpp ${ffiasm}/lib/node_modules/ffiasm/c/splitparstr.cpp ${ffiasm}/lib/node_modules/ffiasm/c/alt_bn128.cpp ${zqfield-default}/lib/fq.cpp ${zqfield-default}/lib/fq.o ${zqfield-default}/lib/fr.cpp ${zqfield-default}/lib/fr.o -o prover -fmax-errors=5 -std=c++17 -pthread -lgmp -lsodium -O3 -fopenmp
        cd ..

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
        cd build
          mkdir -p $out/bin
          cp prover $out/bin
        cd ..
      runHook postInstall'';

    doCheck = false;

    meta = with lib; {
      homepage = "https://github.com/iden3/rapidsnark";
      platforms = with platforms; linux ++ darwin;
    };
  }
