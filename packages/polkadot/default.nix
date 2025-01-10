{
  lib,
  fetchFromGitHub,
  stdenv,
  clang,
  protobuf,
  rocksdb,
  rustPlatform,
  craneLib,
  # Darwin specific:
  libiconv,
  CoreFoundation,
  Security,
  SystemConfiguration,
  libcxx,
}:
{
  enableFastRuntime ? false,
}:
let
  tags = {
    "v0.9.40" = {
      commitSha1 = "a2b62fb872ba22622aaf8e13f9dcd9a4adcc454f";
      srcSha256 = "sha256-xpor2sWdYD9WTtmPuxvC9MRRLPPMk8yHlD7RwtSijqQ=";
    };
    "v0.9.42" = {
      commitSha1 = "9b1fc27cec47f01a2c229532ee7ab79cc5bb28ef";
      srcSha256 = "sha256-73YvkpYoRcM9cvEICjqddxT/gJDcEVfP7QrSSyT92JY=";
    };
    "v0.9.43" = {
      commitSha1 = "ba42b9ce51d25bdaf52d2c61e0763a6e3da50d25";
      srcSha256 = "sha256-KYmMMcQMkkXfWj5ZTr549a/8ftELKo0PUvCrmRMiDaE=";
    };
    "v1.0.0" = {
      commitSha1 = "1ed6e2e50a4ce61f6cda46a730efc11a07b6ebb3";
      srcSha256 = "sha256-amTWHD5T40jfnD7z0ILGEDNu7Sz60puhkB/agI+F/lo=";
    };
  };

  commonArgs = rec {
    version = "0.9.43";

    CC = "clang";
    CXX = "clang++";
    LFLAGS = "-lc++abi";
    NIX_LDFLAGS = "${LFLAGS}";

    src = fetchFromGitHub {
      owner = "paritytech";
      repo = "polkadot";
      rev = tags."v${version}".commitSha1;
      sha256 = tags."v${version}".srcSha256;
    };

    nativeBuildInputs = [
      rustPlatform.bindgenHook
      rocksdb
      clang
    ];

    buildInputs =
      [
        clang
        libcxx
        libcxx.dev
      ]
      ++ lib.optionals stdenv.isDarwin [
        libiconv
        CoreFoundation
        Security
        SystemConfiguration
      ];

    SUBSTRATE_CLI_GIT_COMMIT_HASH = tags."v${version}".commitSha1;
    PROTOC = "${protobuf}/bin/protoc";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  };

  cargoArtifacts = craneLib.buildDepsOnly (
    commonArgs
    // {
      pname = "polkadot";
    }
  );
in
craneLib.buildPackage (
  commonArgs
  // rec {
    pname = "polkadot" + lib.optionalString enableFastRuntime "-fast";
    inherit cargoArtifacts;

    buildFeatures = [ "jemalloc-allocator" ] ++ lib.optional enableFastRuntime "fast-runtime";

    doCheck = false;

    meta = with lib; {
      description = "Polkadot Node Implementation";
      homepage = "https://polkadot.network";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [
        akru
        andresilva
        asymmetric
        FlorianFranzen
        RaghavSood
      ];
      platforms = platforms.unix;
    };
  }
)
