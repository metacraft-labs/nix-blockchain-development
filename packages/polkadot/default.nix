{
  lib,
  fetchFromGitHub,
  writeShellScriptBin,
  stdenv,
  clang,
  llvmPackages,
  protobuf,
  rocksdb,
  rustPlatform,
  craneLib,
  # Darwin specific:
  libiconv,
  CoreFoundation,
  Security,
  SystemConfiguration,
}: {enableFastRuntime ? false}: let
  tags = {
    "v0.9.40" = {
      commitSha1 = "a2b62fb872ba22622aaf8e13f9dcd9a4adcc454f";
      srcSha256 = "sha256-xpor2sWdYD9WTtmPuxvC9MRRLPPMk8yHlD7RwtSijqQ=";
    };
    "v0.9.42" = {
      commitSha1 = "9b1fc27cec47f01a2c229532ee7ab79cc5bb28ef";
      srcSha256 = "sha256-73YvkpYoRcM9cvEICjqddxT/gJDcEVfP7QrSSyT92JY=";
    };
  };
in
  craneLib.buildPackage rec {
    pname = "polkadot";
    version = "0.9.42";

    src = fetchFromGitHub {
      owner = "paritytech";
      repo = "polkadot";
      rev = tags."v${version}".commitSha1;
      sha256 = tags."v${version}".srcSha256;
    };

    cargoSha256 = "sha256-sZ1OwFyww7/xhc92D2qlpYyboTMOgcv8JwmdPskYQTE=";

    buildInputs = lib.optionals stdenv.isDarwin [
      libiconv
      CoreFoundation
      Security
      SystemConfiguration
    ];

    buildFeatures = ["jemalloc-allocator"] ++ lib.optional enableFastRuntime "fast-runtime";

    nativeBuildInputs = [rustPlatform.bindgenHook rocksdb];

    SUBSTRATE_CLI_GIT_COMMIT_HASH = tags."v${version}".commitSha1;
    PROTOC = "${protobuf}/bin/protoc";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";

    # NOTE: We don't build the WASM runtimes since this would require a more
    # complicated rust environment setup and this is only needed for developer
    # environments. The resulting binary is useful for end-users of live networks
    # since those just use the WASM blob from the network chainspec.
    SKIP_WASM_BUILD = 1;

    # We can't run the test suite since we didn't compile the WASM runtimes.
    doCheck = false;

    meta = with lib; {
      description = "Polkadot Node Implementation";
      homepage = "https://polkadot.network";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [akru andresilva asymmetric FlorianFranzen RaghavSood];
      platforms = platforms.unix;
    };
  }
