{pkgs}:
(pkgs.solana-validator.override
  {
    openssl = pkgs.openssl_3;
  })
.overrideAttrs (old: {
  pname = "solana-rust-artifacts";
  # buildAndTestSubdir = null;
  # nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.llvmPackages_13.clang];
  # buildInputs = old.buildInputs ++ [pkgs.openssl];
  # LIBCLANG_PATH = "${pkgs.llvmPackages_13.libclang.lib}/lib";
  # CARGO_FEATURE_VENDORED = "0";
  # OPENSSL_NO_VENDOR = "1";
  # postInstall = ''
  #   mkdir -p $out/bin/sdk/
  #   cp -r ./sdk/bpf $out/bin/sdk/
  # '';
  # patches = old.patches ++ [../cargo-build-bpf/patches/main.rs.diff];
})
