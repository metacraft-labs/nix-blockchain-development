{
  lib,
  buildGoModule,
  fetchFromGitHub,
  blst,
  libusb1,
}:
buildGoModule rec {
  pname = "avalanche-cli";
  version = "1.8.10";

  src = fetchFromGitHub {
    owner = "ava-labs";
    repo = "avalanche-cli";
    rev = "v${version}";
    hash = "sha256-RicLxiTIwGJbFSWWywqN9KEzgU6WB0iR5bC/bWdft6o=";
  };

  proxyVendor = true;
  vendorHash = "sha256-F2prsymg2ean7Er/tTYVUrdyOdtMhxk5/pyOJzONrr8=";

  doCheck = false;

  ldflags = [
    "-X=github.com/ava-labs/avalanche-cli/cmd.Version=${version}"
  ];

  buildInputs = [
    blst
    libusb1
  ];

  meta = {
    description = "Avalanche CLI is a command line tool that gives developers access to everything Avalanche.";
    homepage = "https://github.com/ava-labs/avalanche-cli";
    license = lib.licenses.unfree; # non-sublicensable, field-of-use restrictions
    maintainers = with lib.maintainers; [ ];
    mainProgram = "avalanche-cli";
  };
}
