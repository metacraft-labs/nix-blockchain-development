{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "circom";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "iden3";
    repo = "circom";
    rev = "47883d98c45fe25c6d010f16b717cca6d0dea745";
    sha256 = "sha256-Yo1TLg/mq2IdbHCBel0sKAeZb//bKrUzGpaXQjC/32k=";
  };

  doCheck = false;

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };
}
