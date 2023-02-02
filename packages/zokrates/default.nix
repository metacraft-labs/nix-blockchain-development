{
  lib,
  fetchgit,
  pkgs,
}:
with pkgs;
  rustPlatform.buildRustPackage rec {
    pname = "zokrates";
    version = "0.8.4";
    cargoBuildFlags = "-p zokrates_cli";

    src = fetchgit {
      url = "https://github.com/Zokrates/ZoKrates.git";
      rev = "${version}";
      sha256 = "sha256-++xQJjl1cK7PrqOJ8aiA8gmi+QSDB8jiKZ/bNbZnTyw=";
    };

    cargoSha256 = "sha256-yXCgu07OCDbvatZlPdF2g3ek+0NxOmq31j8xFYbCmpI=";

    nativeBuildInputs = [pkg-config rust-bin.nightly."2022-07-01".default];
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

    buildInputs = [];
  }
