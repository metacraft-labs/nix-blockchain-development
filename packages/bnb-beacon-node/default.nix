{
  lib,
  buildGoModule,
  fetchFromGitHub,
  libpcap,
}:
buildGoModule rec {
  pname = "bnb-beacon-node";
  version = "0.10.16";

  src = fetchFromGitHub {
    owner = "bnb-chain";
    repo = "node";
    rev = "v${version}";
    hash = "sha256-wW2KJf6W4vyBLcqcZ0Efb1oEzmztRJtCPdg3GOnoVCc=";
  };

  vendorHash = "sha256-DQis6uG6E+2KK8gViudIpDTxRO2zRoufuQlkyFXqO7s=";

  proxyVendor = true;

  subPackages = [
    "cmd/bnbcli"
    "cmd/bnbchaind"
  ];

  buildInputs = [
    libpcap
  ];

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/bnb-chain/node";
    changelog = "https://github.com/bnb-chain/node/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mpl20;
    maintainers = with maintainers; [];
    mainProgram = "bnb-beacon-node";
  };

  postInstall = ''
    mkdir $out/data
    cp -r ${./config}/* $out/data
  '';
}
