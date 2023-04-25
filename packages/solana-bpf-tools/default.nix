{pkgs}:
with pkgs;
  stdenv.mkDerivation rec {
    name = "solana-bpf-tools-${version}";
    version = "1.29";
    src = fetchzip {
      url = "https://github.com/solana-labs/bpf-tools/releases/download/v${version}/solana-bpf-tools-linux.tar.bz2";
      sha256 = "sha256-WxO7Jw2EJPP1u2U80MEosjrwPfOAFzvl0ovx3nADtMk=";
      stripRoot = false;
    };

    # TODO autoPatchElf is Linux-specific. We need a cross-platform solution.
    nativeBuildInputs = lib.optionals stdenv.isLinux [autoPatchelfHook gccForLibs.lib];

    buildInputs = with pkgs; [
      zlib
      openssl_1_1
    ];

    installPhase = ''
      mkdir -p $out/dependencies/bpf-tools;
      cp -r $src/llvm $out/dependencies/bpf-tools/;

      mkdir -p $TMP/rust
      cp -r $src/rust $TMP/rust;
      rm -rf $TMP/rust/lib/rustlib/src
      cp -r $TMP/rust $out/dependencies/bpf-tools/;

      mkdir -p $out/bin/sdk/bpf/
      cp -r $out/dependencies $out/bin/sdk/bpf/
    '';

    meta = with lib; {
      homepage = "https://github.com/solana-labs/bpf-tools/releases";
      platforms = with platforms; linux ++ darwin;
    };
  }
