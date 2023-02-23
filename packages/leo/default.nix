{
  stdenv,
  lib,
  pkgs,
  rustPlatform,
  fetchgit,
}:
rustPlatform.buildRustPackage rec {
  pname = "leo";
  version = "1.6.2";

  src = fetchgit {
    url = "https://github.com/AleoHQ/leo";
    rev = "v${version}";
    sha256 = "sha256-is4i+8ChPEzpyEIiul+lxQgLyIB3pAubZjuIgC4W1VM=";
  };

  nativeBuildInputs = with pkgs; [rust-bin.stable."1.66.0".default];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };
}
