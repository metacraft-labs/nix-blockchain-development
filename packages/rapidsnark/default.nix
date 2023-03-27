{pkgs}:
with pkgs;
  buildNpmPackage rec {
    pname = "rapidsnark";
    version = "2023-03-08";
    src = fetchFromGitHub {
      owner = "iden3";
      repo = "rapidsnark";
      rev = "8b254247fd34b523c79ec1b582a4402343bc8094";
      hash = "sha256-IqQ/Rc1l5MzFeoIjxRz9Oj6uzElAe6hEbhE97+3Ct4c=";
    };

    npmDepsHash = "sha256-/x6ey3HjVmOAbTaQ+7c9lc3IvyqsYHpqzqMWrKpE2DU=";

    npmPackFlags = ["--ignore-scripts"];

    nativeBuildInputs = with pkgs; [gtest nodejs nasm];

    buildInputs = with pkgs; [metacraft-labs.ffiasm nlohmann_json metacraft-labs.pistache metacraft-labs.circom_runtime gmp libsodium];

    buildPhase = ''
      runHook preBuild
      mkdir $out
      mkdir build

      echo createFieldSources
        cd build
          ${metacraft-labs.ffiasm}/bin/buildzqfield -q 21888242871839275222246405745257275088696311157297823662689037894645226208583 -n Fq
          ${metacraft-labs.ffiasm}/bin/buildzqfield -q 21888242871839275222246405745257275088548364400416034343698204186575808495617 -n Fr
          if [ "${lib.boolToString stdenv.isDarwin}" == "true" ]; then
            nasm -fmacho64 --prefix _ fq.asm
            nasm -fmacho64 --prefix _ fr.asm
          else
            nasm -felf64 fq.asm
            nasm -felf64 fr.asm
          fi
        cd ..

      echo buildProverServer
        cd build
          g++ -I. -I../src -I${metacraft-labs.pistache}/include -I${nlohmann_json}/include -I${libsodium.dev}/include -I${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c -I${metacraft-labs.circom_runtime}/lib/node_modules/circom_runtime/c ../src/main_proofserver.cpp ../src/proverapi.cpp ../src/fullprover.cpp ../src/binfile_utils.cpp  ../src/wtns_utils.cpp ../src/zkey_utils.cpp ../src/logger.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/misc.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/naf.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/splitparstr.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/alt_bn128.cpp fq.cpp fq.o fr.cpp fr.o -L${metacraft-labs.pistache}/lib -lpistache -o proverServer -fmax-errors=5 -pthread -std=c++17 -fopenmp -lgmp -lsodium -g -DSANITY_CHECK
        cd ..

      echo buildProver
        cd build
          g++ -I. -I../src -I${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c -I${nlohmann_json}/include -I${libsodium.dev}/include ../src/main_prover.cpp ../src/binfile_utils.cpp ../src/zkey_utils.cpp ../src/wtns_utils.cpp ../src/logger.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/misc.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/naf.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/splitparstr.cpp ${metacraft-labs.ffiasm}/lib/node_modules/ffiasm/c/alt_bn128.cpp fq.cpp fq.o fr.cpp fr.o -o prover -fmax-errors=5 -std=c++17 -pthread -lgmp -lsodium -O3 -fopenmp
        cd ..


        cd build
          mkdir -p $out/lib/node_modules/rapidsnark/build
          mkdir -p $out/bin
          cp {fr,fq}.{asm,cpp,hpp,o} $out/lib/node_modules/rapidsnark/build
          cp prover proverServer $out/bin
        cd ..





      runHook postBuild
    '';

    doCheck = false;

    meta = with lib; {
      homepage = "https://github.com/iden3/rapidsnark";
      platforms = with platforms; linux ++ darwin;
    };
  }
