{
  pkgs,
  ...
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "cargo-stylus";
  version = "0.6.3";

  src = pkgs.fetchFromGitHub {
    owner = "OffchainLabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-iaKTcc0LEwrTwLOwwCwXzFIB1LjRC9Tt2ljklE4ujPg=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  # The binary is installed as cargo-stylus
  doCheck = false;

  meta = {
    description = "CLI tool for Arbitrum Stylus smart contract development";
    homepage = "https://github.com/OffchainLabs/cargo-stylus";
  };
}
