{
  lib,
  buildGoModule,
  fetchFromGitHub,
  libpcap,
}:
buildGoModule rec {
  pname = "bnb-beacon-node";
  version = "0.10.20";

  src = fetchFromGitHub {
    owner = "bnb-chain";
    repo = "node";
    rev = "v${version}";
    hash = "sha256-x7wHdCdGMEhFuBNwYXlOxh6MwCG4uprM9TOxuujccQU=";
  };

  vendorHash = "sha256-HGxUSpnywzSazpnZHk6N3lmk2t1Av4EEIFB1bMHtwoA=";

  proxyVendor = true;

  subPackages = [
    "cmd/bnbcli"
    "cmd/bnbchaind"
  ];

  buildInputs = [
    libpcap
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/bnb-chain/node";
    changelog = "https://github.com/bnb-chain/node/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    mainProgram = "bnb-beacon-node";
  };

  postInstall = ''
    mkdir $out/data
    cp -r ${./config}/* $out/data
  '';
}
