{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
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
      "solana-log-analyzer"
      "solana-net-shaper"
      "solana-sys-tuner"
      "rbpf-cli"
      "solana-validator"
      "solana-ledger-tool"
      "cargo-build-bpf"
      "cargo-test-bpf"
      "solana-dos"
      "solana-install-init"
      "solana-stake-accounts"
      "solana-test-validator"
      "solana-tokens"
      "solana-watchtower"
      "cargo-test-sbf"
      "cargo-build-sbf"
    ]
    ++ [
      # XXX: Ensure `solana-genesis` is built LAST!
      # See https://github.com/solana-labs/solana/issues/5826
      "solana-genesis"
    ],
}:
rustPlatform.buildRustPackage rec {
  pname = "solana";
  version = "1.16.23";

  src = fetchFromGitHub {
    owner = "solana-labs";
    repo = "solana";
    rev = "v${version}";
    hash = "sha256-6xRoJMQYTOhAw09rA8jkBiwq5Ry9mpdVplFHaFExrNg=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "crossbeam-epoch-0.9.5" = "sha256-Jf0RarsgJiXiZ+ddy0vp4jQ59J9m0k3sgXhWhCdhgws=";
      "ntapi-0.3.7" = "sha256-G6ZCsa3GWiI/FeGKiK9TWkmTxen7nwpXvm5FtjNtjWU=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs =
    [
      bzip2
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

  env = {
    OPENSSL_NO_VENDOR = true;
    ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  };

  meta = with lib; {
    description = "Web-Scale Blockchain for fast, secure, scalable, decentralized apps and marketplaces";
    homepage = "https://github.com/solana-labs/solana";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    mainProgram = "solana";
  };
}
