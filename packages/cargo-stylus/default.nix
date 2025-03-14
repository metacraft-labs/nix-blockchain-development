{
  unstable-pkgs,
  ...
}:
with unstable-pkgs;
rustPlatform.buildRustPackage rec {
  pname = "cargo-stylus";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "OffchainLabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+wHGGzd4GWWmHnxset90s9FAzOjF7VMr58HZHUB+OwQ=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  buildInputs = [
    cargo
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  meta = {
    description = "Cargo subcommand for developing Arbitrum Stylus projects in Rust.";
    homepage = "https://github.com/OffchainLabs/cargo-stylus";
    license = [
      lib.licenses.mit
      lib.licenses.asl20
    ];
  };
}
