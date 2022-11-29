{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "neard";
  version = "1.29.1";

  src = fetchFromGitHub {
    owner = "near";
    repo = "nearcore";
    rev = "47883d98c45fe25c6d010f16b717cca6d0dea745";
    sha256 = "sha256-Yo1TLg/mq2IdbHCBel0sKAeZb//bKrUzGpaXQjC/32k=";
  };

  doCheck = false;

  # postPatch = ''
  #   cp ${./Cargo.lock} Cargo.lock
  # '';

  # cargoLock = let
  #   fixupLockFile = path: (builtins.readFile path);
  # in {
  #   lockFileContents = fixupLockFile ./Cargo.lock;
  # };
}
