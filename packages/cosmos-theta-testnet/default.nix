{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchurl,
}: let
  genesis = fetchurl {
    url = "https://github.com/hyphacoop/testnets/raw/add-theta-testnet/v7-theta/local-testnet/genesis.json.gz";
    sha256 = "0041873l59xapdxgb22b61rvqqp48laa3a5xcyim2dmjbc01zb5b";
  };

  validator_key = fetchurl {
    url = "https://github.com/hyphacoop/testnets/raw/add-theta-testnet/v7-theta/local-testnet/priv_validator_key.json";
    sha256 = "0h4qx6iaqvklrzhj15nz8lz61ckf4dbfwp93fafmy4c2dc43fva8";
  };
in
  buildGoModule rec {
    pname = "cosmos-theta-testnet";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "cosmos";
      repo = "gaia";
      rev = "edb81681654d0d111652df9fd933ed6e69d3c9fe";
      sha256 = "sha256-x0CvVxGKeDPY/oKHSUYffvFq0x83jfe2O7GSLJ8zevc=";
    };

    preCheck = ''
      export HOME=$TMPDIR
    '';
    vendorSha256 = "sha256-fGRLYkxZDowkuHcX26aRclLind0PRKkC64CQBVrnBr8=";
    doCheck = false;
    meta = with lib; {
      description = "Simple command-line snippet manager, written in Go";
      homepage = "https://github.com/cosmos/gaia";
      license = licenses.mit;
      maintainers = with maintainers; [];
    };

    postInstall = ''
      mkdir $out/data
      gunzip -c ${genesis} > $out/data/genesis.json
      cp ${validator_key} $out/data/priv_validator_key.json
    '';
  }
