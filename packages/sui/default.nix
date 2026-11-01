{
  lib,
  stdenv,
  rustFromToolchainFile,
  craneLib,
  fetchFromGitHub,
  pkg-config,
  openssl,
  cmake,
  perl,
  llvmPackages,
  ...
}:
let
  src = fetchFromGitHub {
    owner = "MystenLabs";
    repo = "sui";
    rev = "mainnet-v${version}";
    hash = "sha256-bBldssmoc+SAtdB62VJ9bh/yAz4PdJnpkiLPJ7uzEPg=";
  };

  version = import ./version.nix;

  rust-toolchain = rustFromToolchainFile {
    dir = src;
    sha256 = "sha256-p8h3Sl/YRByZfZTAKXdsvF6xEenXKrXSVvpphmZENH4=";
  };

  crane = craneLib.overrideToolchain rust-toolchain;

  # Two git dependencies cannot be packaged by crane's vendoring as published,
  # so their checkouts are patched before vendoring:
  #  - The tabled fork (zhiburt/tabled@e449317) has a broken symlink at
  #    tabled/examples/show/LICENSE -> ../../LICENSE, but tabled/LICENSE
  #    doesn't exist (only tabled/LICENSE-MIT). crane's rg --follow --files
  #    fails when it encounters the dangling symlink.
  #  - mysten-sim (6b8e1e8, locked by sui 1.82.3; 213e543, locked by 1.68.1,
  #    is the same) declares `readme = "README.md"` in
  #    mocked-crates/futures-timer/Cargo.toml without shipping that file, and
  #    the cargo crane vendors with refuses the crate ("readme `README.md`
  #    does not appear to exist"). Older toolchains accepted it, which is why
  #    1.68.1 was once built and cached; rebuilt with the current inputs it
  #    fails the same way on Linux. An empty README satisfies the manifest.
  cargoVendorDir = crane.vendorCargoDeps {
    inherit src;
    overrideVendorGitCheckout =
      let
        fromRepo = name: ps: builtins.any (p: lib.hasInfix name (p.source or "")) ps;
      in
      ps: drv:
      if fromRepo "tabled" ps then
        drv.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # Fix broken symlink: tabled/examples/show/LICENSE -> ../../LICENSE
            cp tabled/LICENSE-MIT tabled/LICENSE
          '';
        })
      else if fromRepo "mysten-sim" ps then
        drv.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # Provide the readme futures-timer's manifest names.
            [ -e mocked-crates/futures-timer/README.md ] \
              || touch mocked-crates/futures-timer/README.md
          '';
        })
      else
        drv;
  };

  commonArgs = {
    pname = "sui";
    inherit src version cargoVendorDir;

    nativeBuildInputs = [
      pkg-config
      openssl
      cmake
      perl # needed by openssl-sys build script
      llvmPackages.libclang # needed by librocksdb-sys (bindgen)
    ];

    buildInputs = [
      stdenv.cc.cc.lib # libstdc++ needed by rocksdb at runtime
    ];

    # Ensure the linker embeds the path to libstdc++ in the binary RPATH
    RUSTFLAGS = "-C link-arg=-Wl,-rpath,${stdenv.cc.cc.lib}/lib";

    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    GIT_REVISION = "mainnet-v${version}";

    # Some workspace members lack src/ directories, breaking cargo's manifest
    # parsing. Create minimal stubs to keep Cargo.lock valid.
    postPatch = ''
      for d in crates/sui-cost crates/sui-move-lsp crates/sui-e2e-tests \
                crates/sui-json-rpc-tests \
                external-crates/move/crates/move-ir-compiler-transactional-tests; do
        if [ -d "$d" ] && [ ! -f "$d/src/lib.rs" ] && [ ! -f "$d/src/main.rs" ]; then
          mkdir -p "$d/src"
          touch "$d/src/lib.rs"
        fi
      done
    '';
  };

  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // {
    inherit cargoArtifacts;

    cargoBuildCommand = "cargo build --release -p sui --features tracing";

    doCheck = false;
  }
)
