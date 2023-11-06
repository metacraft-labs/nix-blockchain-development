{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchurl,
}: let
  dir = "local/previous-local-testnets/v7-theta";
  v7-local-testnet-files = fetchFromGitHub {
    owner = "hyphacoop";
    repo = "testnets";
    rev = "16f13e4ec649445387d4be0edf92eaaae7619c88";
    sparseCheckout = [dir];
    hash = "sha256-TFN0CtaSsfEHBxYhoFl8m5pu0iVLoW4aK2ArkyQOymk=";
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
      mainProgram = "gaiad";
      description = "Simple command-line snippet manager, written in Go";
      homepage = "https://github.com/cosmos/gaia";
      license = licenses.mit;
      maintainers = with maintainers; [];
    };

    postInstall = ''
      mkdir -p $out/data
      gunzip -c ${v7-local-testnet-files}/${dir}/genesis.json.gz > $out/data/genesis.json
      cp ${v7-local-testnet-files}/${dir}/priv_validator_key.json $out/data
    '';
  }
