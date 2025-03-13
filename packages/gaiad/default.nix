{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gaia";
  version = "22.3.1";

  src = fetchFromGitHub {
    owner = "cosmos";
    repo = "gaia";
    rev = "v${version}";
    sha256 = "sha256-vJi4I3e14EALE4Ac6gyaBq3wLd5mUj4oeXo9CbV1U4c=";
  };

  vendorHash = "sha256-X2BtJ9g4AqH2z2wnzPYlaX30dY4KKgD6KVv5227lGbE=";

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
