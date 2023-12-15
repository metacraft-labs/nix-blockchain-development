{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  udev,
  bzip2,
  openssl,
  stdenv,
  darwin,
  rocksdb,
  # Taken from https://github.com/solana-labs/solana/blob/master/scripts/cargo-install-all.sh#L84
  solanaPkgs ?
    [
      "solana"
      "solana-bench-tps"
      "solana-faucet"
      "solana-gossip"
      "solana-install"
      "solana-keygen"
      "solana-ledger-tool"
      "solana-log-analyzer"
      "solana-net-shaper"
      "solana-validator"
      "rbpf-cli"
      "cargo-build-bpf"
      "cargo-build-sbf"
      "cargo-test-bpf"
      "cargo-test-sbf"
      "solana-dos"
      "solana-install-init"
      "solana-stake-accounts"
      "solana-test-validator"
      "solana-tokens"
      "solana-watchtower"
    ]
    ++ [
      # XXX: Ensure `solana-genesis` is built LAST!
      # See https://github.com/solana-labs/solana/issues/5826
      "solana-genesis"
    ],
}:
rustPlatform.buildRustPackage rec {
  pname = "solana";
  version = "1.17.10";

  src = fetchFromGitHub {
    owner = "solana-labs";
    repo = "solana";
    rev = "v${version}";
    hash = "sha256-iDQfHkr8G3e97IVpuE6U/h0Fykt/rFDFBpKya+0vLIE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "crossbeam-epoch-0.9.5" = "sha256-Jf0RarsgJiXiZ+ddy0vp4jQ59J9m0k3sgXhWhCdhgws=";
      "tokio-1.29.1" = "sha256-Z/kewMCqkPVTXdoBcSaFKG5GSQAdkdpj3mAzLLCjjGk=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs =
    [openssl]
    ++ lib.optionals stdenv.isLinux [udev]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk_11_0;
      with darwin.apple_sdk_11_0.frameworks; [
        libcxx
        IOKit
        Security
        AppKit
        System
        Libsystem
      ]
    );

  cargoBuildFlags = builtins.map (n: "--bin=${n}") solanaPkgs;

  env = {
    OPENSSL_NO_VENDOR = true;
    ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  };

  meta = with lib; {
    description = "Web-Scale Blockchain for fast, secure, scalable, decentralized apps and marketplaces";
    homepage = "https://github.com/solana-labs/solana";
    changelog = "https://github.com/solana-labs/solana/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    mainProgram = "solana";
  };
}
