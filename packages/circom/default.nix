{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "circom";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "iden3";
    repo = "circom";
    rev = "v${version}";
    sha256 = "sha256-T6kRa4TCIoJh7zHLanOb2w6WcIVapF6apblxjg5OxIk=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };
}
