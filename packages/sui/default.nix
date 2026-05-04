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
    hash = "sha256-pYToMUW96g7GeVZSfIU+pwrPg7Qyimo90cSSy0woiSc=";
  };

  version = "1.70.2";

  rust-toolchain = rustFromToolchainFile {
    dir = src;
    sha256 = "sha256-sqSWJDUxc+zaz1nBWMAJKTAGBuGWP25GCftIOlCEAtA=";
  };

  crane = craneLib.overrideToolchain rust-toolchain;

  # The tabled fork (zhiburt/tabled@e449317) has a broken symlink at
  # tabled/examples/show/LICENSE -> ../../LICENSE, but tabled/LICENSE
  # doesn't exist (only tabled/LICENSE-MIT). crane's rg --follow --files
  # fails when it encounters the dangling symlink.
  cargoVendorDir = crane.vendorCargoDeps {
    inherit src;
    overrideVendorGitCheckout =
      ps: drv:
      if builtins.any (p: lib.hasInfix "tabled" (p.source or "")) ps then
        drv.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # Fix broken symlink: tabled/examples/show/LICENSE -> ../../LICENSE
            cp tabled/LICENSE-MIT tabled/LICENSE
          '';
        })
      else if builtins.any (p: lib.hasInfix "mysten-sim" (p.source or "")) ps then
        drv.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # The mocked futures-timer crate declares readme = "README.md" but
            # the vendored git checkout does not contain that file.
            touch mocked-crates/futures-timer/README.md
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

    CARGO_BUILD_JOBS = "1";

    cargoBuildCommand = "cargo build --release -p sui --features tracing";

    doCheck = false;
  }
)
