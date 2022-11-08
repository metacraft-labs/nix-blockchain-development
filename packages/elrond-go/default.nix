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

    bls-go-binary-headers = fetchgit {
      url = "https://github.com/herumi/bls-go-binary";
      rev = "v1.0.0";
      sha256 = "sha256-JokD6mAmLVKfM4i1lZfj1vcNClHHu/7/v3n7PKH2P4U=";
    };

    vendorSha256 = "sha256-+rHSabNwfiDUBdlNNm494EpGTSy9+R/vrf0VovMEywk=";
    modSha256 = lib.fakeSha256;

    subPackages = ["cmd/node"];

    # Patch is needed to update go.mod to use go 1.18, as otherwise it fails to build
    patches = [./go.mod.patch];

    libos =
      if system == "x86_64-linux"
      then "linux/amd64"
      else if system == "aarch64-linux"
      then "linux/arm64"
      else if system == "x86_64-darwin"
      then "darwin/amd64"
      else if system == "aarch64-darwin"
      then "darwin/arm64"
      else if system == "x86_64-windows"
      then "windows/amd64"
      else "";

    CGO_CFLAGS = "-I${bls-go-binary-headers}/bls/include ";
    CGO_LDFLAGS = "-L${bls-go-binary-headers}/bls/lib/${libos}";

    meta = with lib; {
      description = "Elrond-GO: The official implementation of the Elrond protocol, written in golang. ";
      homepage = "https://github.com/ElrondNetwork/elrond-go";
      license = licenses.gpl3;
    };
  }
