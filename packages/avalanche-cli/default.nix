{pkgs}:
with pkgs;
  buildGoModule rec {
    pname = "avalanche-cli";
    version = "1.3.7";

    src = fetchFromGitHub {
      rev = "v${version}";
      sha256 = "sha256-zk5oWeTeVeTs5bq3UyOwRycK/f859YqIyyZ5sD7KoPI=";
      owner = "ava-labs";
      repo = "avalanche-cli";
    };

    doCheck = false;
    proxyVendor = true;
    vendorSha256 = "sha256-SC+9t2B3W4+4wDQWZqcpU8R1xNH8uc5rF3okLN2Df10=";

    meta = with lib; {
      description = "Avalanche CLI is a command line tool that gives developers access to everything Avalanche.";
      homepage = "https://github.com/ava-labs/avalanche-cli";
      license = licenses.lgpl3;
    };
  }
