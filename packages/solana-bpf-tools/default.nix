{pkgs}:
with pkgs;
  stdenv.mkDerivation rec {
    name = "solana-bpf-tools-${version}";
    version = "1.41";
    src = fetchzip {
      url = "https://github.com/solana-labs/platform-tools/releases/download/v${version}/platform-tools-linux-x86_64.tar.bz2";
      sha256 = "sha256-m+9QArPvapnOO9lMWYZK2/Yog5cVoY9x1DN7JAusYsk=";
      stripRoot = false;
    };

    # TODO autoPatchElf is Linux-specific. We need a cross-platform solution.
    nativeBuildInputs = lib.optionals stdenv.isLinux [autoPatchelfHook gccForLibs.lib];

    buildInputs = with pkgs; [
      python38
      ncurses
      lzma
      libxml2
      zlib
      openssl
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
