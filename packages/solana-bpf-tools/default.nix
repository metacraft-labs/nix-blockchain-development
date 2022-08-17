{pkgs}:
with pkgs;
  stdenv.mkDerivation rec {
    name = "solana-bpf-tools-${version}";
    version = "1.23";
    src = fetchzip {
      url = "https://github.com/solana-labs/bpf-tools/releases/download/v${version}/solana-bpf-tools-linux.tar.bz2";
      sha256 = "sha256-4aWBOAOcGviwJ7znGaHbB1ngNzdXqlfDX8gbZtdV1aA=";
      stripRoot = false;
    };

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = with pkgs; [
      zlib
      stdenv.cc.cc
      openssl
    ];

    installPhase = ''
      mkdir -p $out/dependencies/bpf-tools;
      cp -r $src/llvm $out/dependencies/bpf-tools/;
      cp -r $src/rust $out/dependencies/bpf-tools/;
      chmod 0755 -R $out;
      mkdir -p $out/bin/sdk/bpf/
      cp -r $out/dependencies $out/bin/sdk/bpf/
    '';

    meta = with lib; {
      homepage = "https://github.com/solana-labs/bpf-tools/releases";
      platforms = with platforms; linux ++ darwin;
    };
  }
