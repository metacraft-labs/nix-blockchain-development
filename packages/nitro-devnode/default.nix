{
  foundry,
  pkgs,
  stdenv,
}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "nitro-devnode";
  version = "dd51c52";

  src = fetchFromGitHub {
    owner = "OffchainLabs";
    repo = "nitro-devnode";
    rev = "dd51c52129276f940632a4c4bf13844a93499a9f";
    hash = "sha256-0ppC05xfVOrcn2yATni3n3oh4A8MEMdgvhs8E2wNsr8=";
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
