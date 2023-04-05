{
  pkgs,
  cardano-node,
  cardano-cli,
}: let
  src = pkgs.fetchFromGitHub {
    owner = "metacraft-labs";
    repo = "cardano-private-testnet-setup";
    rev = "7ad1b05b28817a1d6f9e8cd784d1654e92a62f5f";
    hash = "sha256-pzI+Hhs85rdonWRxKiZN7OSgh5fx/u1ip2zHWGpbWMA=";
  };

  graphQLSrc = pkgs.fetchFromGitHub {
    owner = "metacraft-labs";
    repo = "cardano-graphql";
    rev = "5ab2b10349dadb23799ba906d080773ff6c25270";
    hash = "sha256-DHFF/JQNxQJj1WfGaAfIgwLqvudL02o0VCk/VQA8img=";
    fetchSubmodules = true;
  };

  automate = pkgs.writeShellApplication {
    name = "run-cardano-local-testnet";

    runtimeInputs = [cardano-node cardano-cli];
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

  automate-graphql = pkgs.writeShellApplication {
    name = "run-cardano-local-graphql";
    runtimeInputs = [cardano-node cardano-cli pkgs.jq];
    text = ''
      export CARDANO_GRAPHQL_SRC="${graphQLSrc}"
      bash ${./automate-graphql.bash}
    '';
  };

  graphql-down = pkgs.writeShellApplication {
    name = "stop-cardano-local-graphql";
    runtimeInputs = [cardano-node cardano-cli];
    text = ''
      cd ${graphQLSrc}
      docker compose -p testnet down
      docker volume rm -f testnet_db-sync-data
      docker volume rm -f testnet_node-db
      docker volume rm -f testnet_node-ipc
      docker volume rm -f testnet_postgres-data
    '';
  };
in
  pkgs.buildEnv {
    name = "cardano-atomation";
    paths = [automate automate-graphql graphql-down cardano-node cardano-cli];
  }
