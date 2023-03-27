{
  gtest,
  gmp,
  lib,
  zqfield-default,
  stdenv,
  ffiasm-src,
}: let
  ffiasm = "${ffiasm-src}/lib/node_modules/ffiasm";
in
  stdenv.mkDerivation rec {
    pname = "ffiasm";
    version = "0.1.4";
    unpackPhase = ":";
    # installPhase = "mkdir -p $out";
    checkInputs = [gtest gmp zqfield-default];

    checkPhase = ''
      echo testSplitParStr
        g++ -I${gtest.dev}/include -I${ffiasm}/src ${ffiasm}/c/splitparstr.cpp ${ffiasm}/c/splitparstr_test.cpp -L${gtest}/lib -lgtest -pthread -std=c++11 -o splitparsestr_test
        ./splitparsestr_test
      echo testAltBn128
        g++ -I${gtest.dev}/include -I${gmp.dev}/include -I${ffiasm}/c -I${zqfield-default}/lib \
          ${ffiasm}/c/naf.cpp ${ffiasm}/c/splitparstr.cpp ${ffiasm}/c/alt_bn128.cpp ${ffiasm}/c/alt_bn128_test.cpp ${ffiasm}/c/misc.cpp \
          ${zqfield-default}/lib/fq.cpp ${zqfield-default}/lib/fq.o ${zqfield-default}/lib/fr.cpp ${zqfield-default}/lib/fr.o \
          -fmax-errors=5 -pthread -std=c++11 -fopenmp -g \
          -L${gtest}/lib -lgtest  \
          -L${gmp}/lib -lgmp \
          -o altbn128_test
        ./altbn128_test
    '';

    installPhase = ''
      mkdir -p $out
      cp -r ${ffiasm-src}/* $out
    '';

    doCheck = true;

    meta = with lib; {
      homepage = "https://github.com/iden3/ffiasm";
      platforms = with platforms; linux ++ darwin;
    };
  }
