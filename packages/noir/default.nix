{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "noir";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "noir-lang";
    repo = "noir";
    rev = "v${version}";
    sha256 = lib.fakeSha256;
  };

  cargoHash = lib.fakeSha256;
}
