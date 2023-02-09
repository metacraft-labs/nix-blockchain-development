{
  stdenv,
  lib,
  pkgs,
  rustPlatform,
  fetchgit,
}:
rustPlatform.buildRustPackage rec {
  pname = "noir";
  version = "0.1.1";

  src = fetchgit {
    url = "https://github.com/noir-lang/noir";
    rev = "v${version}";
    sha256 = "sha256-w5XcWL0H+EgRUZfD2tm8TGhSiyZPIWVNBmO7zxSnFbo=";
  };

  cargoSha256 = "sha256-T8dZRCX7Prz8AMD5rbJ1zQoN6XEslK33hjzG7T1LJog=";

  buildNoDefaultFeatures = false;
  buildFeatures = ["plonk_bn254_wasm"];
  sourceRoot = "crates/nargo";

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };

  nativeBuildInputs = with pkgs; [cmake llvmPackages.llvm llvmPackages.openmp pkgconfig];
}
