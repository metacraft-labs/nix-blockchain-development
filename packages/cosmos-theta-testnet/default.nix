{
  callPackage,
  fetchFromGitHub,
  runCommand,
  symlinkJoin,
  gaiad,
}:
let
  dir = "local/previous-local-testnets/v7-theta";
  v7-local-testnet-files = fetchFromGitHub {
    owner = "hyphacoop";
    repo = "testnets";
    rev = "16f13e4ec649445387d4be0edf92eaaae7619c88";
    sparseCheckout = [ dir ];
    hash = "sha256-TFN0CtaSsfEHBxYhoFl8m5pu0iVLoW4aK2ArkyQOymk=";
  };
in
symlinkJoin {
  name = "cosmos-theta-testnet";
  paths = [
    gaiad
    (runCommand "create-data-dir" { } ''
      mkdir -p $out/data
      cp ${v7-local-testnet-files}/${dir}/priv_validator_key.json $out/data
      gunzip -c ${v7-local-testnet-files}/${dir}/genesis.json.gz > $out/data/genesis.json
    '')
  ];
  meta = gaiad.meta;
}
