{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
  fetchgit,
}:
rustPlatform.buildRustPackage rec {
  pname = "wee_alloc";
  version = "0.45";

  src = fetchgit {
    url = "https://github.com/rustwasm/wee_alloc";
    rev = "${version}";
    sha256 = lib.fakeSha256;
  };

  doCheck = false;

  # cargoSha256 = lib.fakeSha256;
  cargoLock.lockFile = "${src}/Cargo.lock";

}
