{
  lib,
  buildGoModule,
  fetchFromGitHub,
  libpcap,
}:
buildGoModule rec {
  pname = "bnb-beacon-node";
  version = "0.10.19";

  src = fetchFromGitHub {
    owner = "bnb-chain";
    repo = "node";
    rev = "v${version}";
    hash = "sha256-P+LOMmyLmSo9LnN3h/MvmD2HziUwaP8kbxtvvR2Xc38=";
  };

  vendorHash = "sha256-8mgLgAvsd6MiiuKe2vzflpp/WIAuVbYbND5Y12Wrqks=";

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
