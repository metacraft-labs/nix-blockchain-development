{pkgs}:
with pkgs; let
  inherit (metacraft-labs) pistache circom_runtime ffiasm zqfield-default rapidsnark;
in
  stdenv.mkDerivation rec {
    pname = "rapidsnark-server";

    inherit (rapidsnark) version src nativeBuildInputs doCheck meta;

    buildInputs = rapidsnark.buildInputs ++ [pistache];

    buildPhase = ''
      runHook preBuild
      mkdir $out
      mkdir build

      echo buildProverServer
        cd build
          g++ -I. -I../src -I${zqfield-default}/lib -I${pistache}/include -I${nlohmann_json}/include -I${libsodium.dev}/include -I${ffiasm}/lib/node_modules/ffiasm/c -I${circom_runtime}/lib/node_modules/circom_runtime/c ../src/main_proofserver.cpp ../src/proverapi.cpp ../src/fullprover.cpp ../src/binfile_utils.cpp  ../src/wtns_utils.cpp ../src/zkey_utils.cpp ../src/logger.cpp ${ffiasm}/lib/node_modules/ffiasm/c/misc.cpp ${ffiasm}/lib/node_modules/ffiasm/c/naf.cpp ${ffiasm}/lib/node_modules/ffiasm/c/splitparstr.cpp ${ffiasm}/lib/node_modules/ffiasm/c/alt_bn128.cpp ${zqfield-default}/lib/fq.cpp ${zqfield-default}/lib/fq.o ${zqfield-default}/lib/fr.cpp ${zqfield-default}/lib/fr.o -L${pistache}/lib -lpistache -o proverServer -fmax-errors=5 -pthread -std=c++17 -fopenmp -lgmp -lsodium -g -DSANITY_CHECK
        cd ..

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
        cd build
          mkdir -p $out/bin
          cp proverServer $out/bin
        cd ..
      runHook postInstall'';
  }
