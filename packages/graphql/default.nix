{
  pkgs,
  cardano-node,
  cardano-cli,
  symlinkJoin,
}:
let
in
symlinkJoin rec {
  name = "graphql-${version}";
  version = "0-unstable-2023-05-09";
  src = pkgs.fetchFromGitHub {
    owner = "metacraft-labs";
    repo = "cardano-graphql";
    rev = "5ab2b10349dadb23799ba906d080773ff6c25270";
    hash = "sha256-DHFF/JQNxQJj1WfGaAfIgwLqvudL02o0VCk/VQA8img=";
    fetchSubmodules = true;
  };

  paths = [
    automate-graphql
    graphql-down
  ];

  automate-graphql = pkgs.writeShellApplication {
    name = "run-cardano-local-graphql";
    runtimeInputs = [
      cardano-node
      cardano-cli
      pkgs.jq
    ];
    text = ''
      export CARDANO_GRAPHQL_SRC="${src}"
      bash ${./automate-graphql.bash}
    '';
  };

  graphql-down = pkgs.writeShellApplication {
    name = "stop-cardano-local-graphql";
    runtimeInputs = [
      cardano-node
      cardano-cli
    ];
    text = ''
      cd ${src}
      docker compose -p testnet down
      docker volume rm -f testnet_db-sync-data
      docker volume rm -f testnet_node-db
      docker volume rm -f testnet_node-ipc
      docker volume rm -f testnet_postgres-data
    '';
  };
}
