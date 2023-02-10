{
  stdenv,
  lib,
  pkgs,
  rustPlatform,
  fetchgit,
}:
rustPlatform.buildRustPackage rec {
  pname = "leo";
  version = "1.6.2";

  src = fetchgit {
    url = "https://github.com/AleoHQ/leo";
    rev = "v${version}";
    sha256 = fake.sha256;
  };

  cargoSha256 = fake.sha256;
}
