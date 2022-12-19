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
}: let
  tags = {
    "v0.9.40" = {
      commitSha1 = "a2b62fb872ba22622aaf8e13f9dcd9a4adcc454f";
      srcSha256 = "sha256-xpor2sWdYD9WTtmPuxvC9MRRLPPMk8yHlD7RwtSijqQ=";
    };
  };
in
  craneLib.buildPackage rec {
    pname = "polkadot";
    version = "0.9.40";

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
