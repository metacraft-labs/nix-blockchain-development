{
  stdenv,
  lib,
  darwin,
  rustPlatform,
  fetchFromGitHub,
  fetchgit,
  pkgs,
}:
rustPlatform.buildRustPackage rec {
  pname = "wee_alloc";
  version = "0.4.4";

  src = fetchgit {
    url = "https://github.com/rustwasm/wee_alloc";
    # sha256 = lib.fakeSha256;
    sha256 = "sha256-qu2W6zgPfFTTMbn2RQuSjYfTffZKrXa4eSGdKVNpICE=";
  };

  doCheck = false;

  cargoSha256 = lib.fakeSha256;
  # cargoLock.lockFile = "${src}/Cargo.lock";
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    cp ${./wee_alloc_Cargo.toml} wee_alloc/Cargo.toml
    cp ${./trace-malloc-free_Cargo.toml} trace-malloc-free/Cargo.toml
    cp ${./test_Cargo.toml} test/Cargo.toml
    cp ${./example_Cargo.toml} example/Cargo.toml
    # sed -i 's/{Alloc, AllocErr}/{Allocator, AllocError}/' wee_alloc/src/*.rs
    # sed -i 's/AllocErr>/AllocError>/' wee_alloc/src/*.rs
    # sed -i 's/ Alloc for/ Allocator for/' wee_alloc/src/*.rs
  '';

  nativeBuildInputs = with pkgs; [
    rust-bin.nightly."2021-03-25".minimal #neeeded because wee_alloc is an older project, making use of experimental features
  ];

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };
}
