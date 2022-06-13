finalNixpkgs: prevNixpkgs: let
  solana-artefacts = prevNixpkgs.solana-testnet.overrideAttrs (finalSolanaPkg: prevSolanaPkg: {
    pname = "solana-artefacts";
    buildAndTestSubdir = null;
    nativeBuildInputs = prevSolanaPkg.nativeBuildInputs ++ [finalNixpkgs.llvmPackages_13.clang];
    buildInputs = prevSolanaPkg.buildInputs ++ [finalNixpkgs.openssl];
    LIBCLANG_PATH = "${finalNixpkgs.llvmPackages_13.libclang.lib}/lib";
    CARGO_FEATURE_VENDORED = "0";
    OPENSSL_NO_VENDOR = "1";
    postInstall = ''
      mkdir -p $out/bin/sdk/
      cp -r ./sdk/bpf $out/bin/sdk/
    '';
    patches = prevSolanaPkg.patches ++ [./packages/cargo-build-bpf/patches/main.rs.diff];
  });

  solana-bpf-tools = prevNixpkgs.callPackage ./packages/solana-bpf-tools {};
in {
  metacraft-labs = {
    solana = prevNixpkgs.stdenv.mkDerivation rec {
      name = "solana-${version}";
      version = "1.23.1";

      phases = ["installPhase"];

      installPhase = ''
        mkdir -p $out
        cp -rf ${solana-artefacts}/* $out
        chmod 0755 -R $out;

        mkdir -p $out/bin/sdk/bpf
        cp -rf ${solana-bpf-tools}/* $out/bin/sdk/bpf/
        chmod 0755 -R $out;
      '';

      meta = with prevNixpkgs.lib; {
        homepage = "https://github.com/solana-labs/solana";
        platforms = platforms.linux;
      };
    };
  };
}
