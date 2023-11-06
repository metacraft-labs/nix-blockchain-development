{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gaia";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cosmos";
    repo = "gaia";
    rev = "edb81681654d0d111652df9fd933ed6e69d3c9fe";
    sha256 = "sha256-x0CvVxGKeDPY/oKHSUYffvFq0x83jfe2O7GSLJ8zevc=";
  };

  vendorSha256 = "sha256-fGRLYkxZDowkuHcX26aRclLind0PRKkC64CQBVrnBr8=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/cosmos/gaia";
    license = licenses.mit;
    maintainers = with maintainers; [];
    description = ''
      The Cosmos Hub is built using the Cosmos SDK and compiled to a binary
      called gaiad (Gaia Daemon). The Cosmos Hub and other fully sovereign
      Cosmos SDK blockchains interact with one another using a protocol called
      IBC that enables Inter-Blockchain Communication.
    '';
  };
}
