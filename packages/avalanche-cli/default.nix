{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "avalanche-cli";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "ava-labs";
    repo = "avalanche-cli";
    rev = "v${version}";
    hash = "sha256-KhUPQVOHHbRNhnEzHVPSB1JMgtbJKsm2NYMtIAK8kk4=";
  };

  doCheck = false;
  proxyVendor = true;
  vendorHash = "sha256-vhytojvmCOakN9RubjKkFnfA8tzOsOb+hKuACeQGSk4=";

  meta = with lib; {
    description = "Avalanche CLI is a command line tool that gives developers access to everything Avalanche.";
    homepage = "https://github.com/ava-labs/avalanche-cli";
    license = licenses.lgpl3;
  };
}
