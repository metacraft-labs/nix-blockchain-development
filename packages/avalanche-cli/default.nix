{pkgs}:
with pkgs;
  buildGoModule rec {
    pname = "avalanche-cli";
    version = "1.2.6";

    src = fetchFromGitHub {
      rev = "v${version}";
      sha256 = "sha256-j4Sh+YeLefWllaMNvfu/t253DCvdDpRY6tmrmuttSm0=";
      owner = "ava-labs";
      repo = "avalanche-cli";
    };

    doCheck = false;
    proxyVendor = true;
    vendorSha256 = "sha256-tWitBzhkg8l4qesiFXHBW0j4FWw85tMtDLq2DsriGfc=";

    meta = with lib; {
      description = "Avalanche CLI is a command line tool that gives developers access to everything Avalanche.";
      homepage = "https://github.com/ava-labs/avalanche-cli";
      license = licenses.lgpl3;
    };
  }
