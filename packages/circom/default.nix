{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "circom";
  version = "2.1.5";

  buildInputs =
    []
    ++ (
      lib.optionals stdenv.isDarwin [darwin.apple_sdk.frameworks.Security]
    );

  src = fetchFromGitHub {
    owner = "iden3";
    repo = "circom";
    rev = "v${version}";
    hash = "sha256-enZr1fkiUxDDDzajsd/CTV7DN//9xP64IyKLQSaJqXk=";
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
