{
  foundry,
  pkgs,
  stdenv,
}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "nitro-devnode";
  version = "15208c2";

  src = fetchFromGitHub {
    owner = "OffchainLabs";
    repo = "nitro-devnode";
    rev = "15208c2d8834ddc2b2ade63fb9d658f7b2a55f87";
    hash = "sha256-qINoaKVwVybwFOR5W5UlbFphsiRumfe/vV6sMabFHD4=";
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
