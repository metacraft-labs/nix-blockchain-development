{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
  fetchgit,
}:
rustPlatform.buildRustPackage rec {
  pname = "neard";
  version = "1.29.1";

  src = fetchgit {
    url = "https://github.com/near/nearcore";
    rev = "${version}";
    sha256 = "sha256-TmmGLrDpNOfadOIwmG7XRgI89XQjaqIavxCEE2plumc=";
  };

  doCheck = false;

  cargoSha256 = lib.fakeSha256;
  # cargoLock.lockFile = "${src}/Cargo.lock";
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };
}
