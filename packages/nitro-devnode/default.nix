{
  foundry,
  pkgs,
  stdenv,
}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "nitro-devnode";
  version = "4c7e5f2";

  src = fetchFromGitHub {
    owner = "OffchainLabs";
    repo = "nitro-devnode";
    rev = "4c7e5f2ed12f29bb5f09a0ac0acf0ec167904434";
    hash = "sha256-AA9+fV7GslyhokDR69I3KDNvyfRoGyPZ4GEY9BqzBuU=";
  };

  buildInputs = [
    bash
    docker
    foundry
  ];

  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/run-dev-node.sh $out/bin/run-nitro-devnode
  '';

  meta = {
    description = "A script for running an Arbitrum Nitro dev node and deploying contracts for testing.";
    homepage = "https://github.com/OffchainLabs/nitro-devnode";
    license = [
      lib.licenses.asl20
    ];
  };
}
