{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gaia";
  version = "23.1.0";

  src = fetchFromGitHub {
    owner = "cosmos";
    repo = "gaia";
    rev = "v${version}";
    sha256 = "sha256-MAYklg6EJy9z8o9KR5zJmSeUNTsqozodMIsLe1N2C/M=";
  };

  vendorHash = "sha256-/+gjzyoVy46NTt+H/vXiPVGcs+VEop5OGcnqjNKPhJY=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/cosmos/gaia";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    description = ''
      The Cosmos Hub is built using the Cosmos SDK and compiled to a binary
      called gaiad (Gaia Daemon). The Cosmos Hub and other fully sovereign
      Cosmos SDK blockchains interact with one another using a protocol called
      IBC that enables Inter-Blockchain Communication.
    '';
  };
}
