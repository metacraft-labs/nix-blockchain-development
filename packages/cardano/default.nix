{
  pkgs,
  cardano-node,
  cardano-cli,
  graphql,
  symlinkJoin,
}:
let
in
symlinkJoin rec {
  name = "cardano-automation-${version}";
  version = "0-unstable-2023-04-25";
  paths = [
    graphql
    automate
    cardano-node
    cardano-cli
  ];
  src = pkgs.fetchFromGitHub {
    owner = "metacraft-labs";
    repo = "cardano-private-testnet-setup";
    rev = "7ad1b05b28817a1d6f9e8cd784d1654e92a62f5f";
    hash = "sha256-pzI+Hhs85rdonWRxKiZN7OSgh5fx/u1ip2zHWGpbWMA=";
  };

  automate = pkgs.writeShellApplication {
    name = "run-cardano-local-testnet";

    runtimeInputs = [
      cardano-node
      cardano-cli
    ];
    text = ''
      cd ${src}
      if [ -z "$CARDANO_TESTNET_DIR" ]; then
        echo "Error: CARDANO_TESTNET_DIR is not set."
        echo "Please set the environment variable and try again."
        exit 1
      fi
      export CARDANO_TESTNET_DIR="$CARDANO_TESTNET_DIR"
      ${src}/scripts/automate.sh
    '';
  };
}
