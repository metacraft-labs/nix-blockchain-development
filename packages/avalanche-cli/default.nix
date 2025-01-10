{
  lib,
  buildGoModule,
  fetchFromGitHub,
  blst,
  libusb1,
}:
buildGoModule rec {
  pname = "avalanche-cli";
  version = "unstable-2024-11-23";

  src = fetchFromGitHub {
    owner = "ava-labs";
    repo = "avalanche-cli";
    rev = "6debe4169dce2c64352d8c9d0d0acac49e573661";
    hash = "sha256-kYEgKpR6FM3f6Lq3Wxhi8MVh8ojxyqFYgjeu2E8lNcs=";
  };

  proxyVendor = true;
  vendorHash = "sha256-FLuu2Q9O4kPtdT1LWaClv+96G0m0PFpZx22506V+Sts=";

  doCheck = false;

  ldflags = [
    "-X=github.com/ava-labs/avalanche-cli/cmd.Version=${version}"
  ];

  buildInputs = [
    blst
    libusb1
  ];

  meta = {
    description = "";
    homepage = "https://github.com/ava-labs/avalanche-cli";
    # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ ];
    mainProgram = "avalanche-cli";
  };
}
