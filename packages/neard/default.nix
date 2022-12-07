{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
  fetchgit,
  metacraft-labs,
}:
rustPlatform.buildRustPackage rec {
  pname = "neard";
  version = "1.29.3";

  src = fetchgit {
    url = "https://github.com/near/nearcore";
    rev = "${version}";
    # sha256 = lib.fakeSha256;
    sha256 = "sha256-Qbpp+ITWVFbigWLdSDHAo5JhHejEN2FknRIjcpcS2wY=";
  };

  nativeBuildInputs = [metacraft-labs.wee_alloc];

  doCheck = false;

  cargoSha256 = lib.fakeSha256;
  # cargoLock.lockFile = "${src}/Cargo.lock";
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    cp ${./Cargo.toml} Cargo.toml
    sed -i 's/base64 = "0.13"/base64 = "0.13.1"/' core/primitives-core/Cargo.toml runtime/near-test-contracts/test-contract-rs/Cargo.toml
    # cp ${./core_crypto.toml} core/crypto/Cargo.toml
  '';

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };
}
