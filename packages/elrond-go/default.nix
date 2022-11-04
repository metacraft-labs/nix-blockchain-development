{pkgs}:
with pkgs;
  buildGoModule rec {
    pname = "elrond-go";
    version = "1.3.44";

    src = fetchgit {
      url = "https://github.com/ElrondNetwork/elrond-go";
      rev = "v${version}";
      sha256 = "sha256-GbYhgFaaytIwd0X58/XcuP69hewO6nH7UgHEj3h7ToU=";
    };

    vendorSha256 = "sha256-+rHSabNwfiDUBdlNNm494EpGTSy9+R/vrf0VovMEywk=";
    modSha256 = lib.fakeSha256;

    subPackages = ["cmd/node"];

    # Patch is needed to update go.mod to use go 1.18, as otherwise it fails to build
    patches = [./go.mod.patch];

    nativeBuildInputs = [metacraft-labs.mcl metacraft-labs.bls];

    CGO_CFLAGS = "-I \"${metacraft-labs.mcl}/include\" -I \"${metacraft-labs.bls}/include\"";

    meta = with lib; {
      description = "Elrond-GO: The official implementation of the Elrond protocol, written in golang. ";
      homepage = "https://github.com/ElrondNetwork/elrond-go";
      license = licenses.gpl3;
    };
  }
