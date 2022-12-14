{pkgs}:
with pkgs;
  buildGoModule rec {
    pname = "elrond-proxy-go";
    version = "1.1.1-rc.2";

    src = fetchgit {
      url = "https://github.com/Fantom-foundation/go-opera";
      rev = "v${version}";
      sha256 = lib.fakeSha256;
    };

    vendorSha256 = lib.fakeSha256;
    modSha256 = lib.fakeSha256;

    meta = with lib; {
      description = "Opera blockchain protocol secured by the Lachesis consensus algorithm ";
      homepage = "https://github.com/ElrondNetwork/elrond-proxy-go";
      license = licenses.lgpl3;
    };
  }
