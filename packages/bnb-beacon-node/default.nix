{
  lib,
  buildGoModule,
  fetchFromGitHub,
  libpcap,
}:
buildGoModule rec {
  pname = "bnb-beacon-node";
  version = "0.10.24";

  src = fetchFromGitHub {
    owner = "bnb-chain";
    repo = "node";
    rev = "v${version}";
    hash = "sha256-0pxlU+XE6HsItC0X4p1ZysZA1YPI+/z9vhnwhpc1dZQ=";
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
