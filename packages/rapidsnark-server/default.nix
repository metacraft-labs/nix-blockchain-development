{
  stdenv,
  pistache,
  ffiasm,
  zqfield-default,
  rapidsnark,
}: let
  ffiasm-c = "${ffiasm}/lib/node_modules/ffiasm/c";
in
  stdenv.mkDerivation rec {
    pname = "rapidsnark-server";
    inherit (rapidsnark) version src nativeBuildInputs doCheck meta;
    buildInputs = rapidsnark.buildInputs ++ [pistache];

    buildPhase = ''
      mkdir -p $out/bin
      c++ \
        -I{${ffiasm-c},${zqfield-default}/lib} \
        $(pkg-config --cflags --libs nlohmann_json libpistache libsodium) \
        ./src/{binfile_utils,fullprover,main_proofserver,logger,proverapi,wtns_utils,zkey_utils}.cpp \
        ${ffiasm-c}/{alt_bn128,misc,naf,splitparstr}.cpp \
        ${zqfield-default}/lib/{fq,fr}.{cpp,o} \
        -L${pistache}/lib -lpistache \
        -pthread -std=c++17 -fopenmp -lgmp -lsodium -g -DSANITY_CHECK \
        -o $out/bin/proverServer
    '';
  }
