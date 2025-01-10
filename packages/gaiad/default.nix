{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gaia";
  version = "15.1.0";

  src = fetchFromGitHub {
    owner = "cosmos";
    repo = "gaia";
    rev = "v${version}";
    sha256 = "sha256-lCglXCEkKNlpcjcsQcWz7vrl3/RQhUOMhOWos0bof/M=";
  };

  vendorHash = "sha256-cnl3LsZiaMtFdTeYV5FcGWW9WnusqOKY/KmxC8I8Cw0=";

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
