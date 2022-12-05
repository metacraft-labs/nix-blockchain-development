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
  version = "0.4.5";

  src = fetchgit {
    url = "https://github.com/rustwasm/wee_alloc";
    rev = "${version}";
    # sha256 = lib.fakeSha256;
    sha256 = "sha256-4MO7R7EVP3L16OLelmnyu41XtK69glnrk+97kfHaH7I=";
  };

  doCheck = false;

  cargoSha256 = lib.fakeSha256;
  cargoLock.lockFile = "${src}/Cargo.lock";

}
