{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gaia";
  version = "23.0.0";

  src = fetchFromGitHub {
    owner = "cosmos";
    repo = "gaia";
    rev = "v${version}";
    sha256 = "sha256-/33/An/ihlmHr29NMK7k98KGfgFMmmZB/bGrfYr/FoM=";
  };

  vendorHash = "sha256-ASO317I8wc1XgSFZVTTrlWpHeDJ4Kcl54WMYHRXXajc=";

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
