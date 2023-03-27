{pkgs}:
with pkgs;
  buildNpmPackage rec {
    pname = "ffiasm";
    version = "0.1.4";
    src = fetchFromGitHub {
      owner = "iden3";
      repo = "ffiasm";
      rev = "v${version}";
      hash = "sha256-nwDJi9HWCdhfUD3Os8MzngQq7SH6gx52vp77UwS2DLw=";
    };

    npmDepsHash = "sha256-xWXEcNDkIZhDjm5h6yweGkVjbo3mWKezg3wfTCkiOEE=";

    npmPackFlags = ["--ignore-scripts"];

    nativeBuildInputs = with pkgs; [gtest nodejs gmp nasm];

    buildInputs = with pkgs; [];

    buildPhase = ''
      runHook preBuild
      mkdir $out
      mkdir build
      cd build

      echo cleanAll
      echo downloadGoogleTest
      echo compileGoogleTest

      echo createFieldSources
        node ../src/buildzqfield.js -q 21888242871839275222246405745257275088696311157297823662689037894645226208583 -n Fq
        node ../src/buildzqfield.js -q 21888242871839275222246405745257275088548364400416034343698204186575808495617 -n Fr
        if [ "${lib.boolToString stdenv.isDarwin}" == "true" ]; then
          nasm -fmacho64 --prefix _ fq.asm
          nasm -fmacho64 --prefix _ fr.asm
        else
          nasm -felf64 fq.asm
          nasm -felf64 fr.asm
        fi

        mkdir -p $out/lib/node_modules/ffiasm/build
        cp {fr,fq}.{asm,cpp,hpp,o} $out/lib/node_modules/ffiasm/build

      cd ..
      runHook postBuild
    '';

    checkPhase = ''
      cd build
      echo testSplitParStr
        g++ -I${gtest.dev}/include -I. -I../src ../c/splitparstr.cpp ../c/splitparstr_test.cpp -L${gtest}/lib -lgtest -pthread -std=c++11 -o splitparsestr_test
        ./splitparsestr_test
      echo testAltBn128
        g++ -I${gtest.dev}/include -I${gmp.dev}/include -I. -I../c ../c/naf.cpp ../c/splitparstr.cpp ../c/alt_bn128.cpp ../c/alt_bn128_test.cpp ../c/misc.cpp fq.cpp fq.o fr.cpp fr.o -L${gtest}/lib -lgtest -o altbn128_test -fmax-errors=5 -pthread -std=c++11 -fopenmp -L${gmp}/lib -lgmp -g
        ./altbn128_test
      echo benchMultiExpG1
      echo benchMultiExpG2
      cd ..
    '';

    doCheck = true;

    meta = with lib; {
      homepage = "https://github.com/iden3/ffiasm";
      platforms = with platforms; linux ++ darwin;
    };
  }
