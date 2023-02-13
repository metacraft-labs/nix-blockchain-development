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
    sha256 = "sha256-3l9ifrF5rpOrD4S4WSjWiNgsCBwcF91k3bSnjR4nYBQ=";
    leaveDotGit = true;
  };

  cargoSha256 = "sha256-T8dZRCX7Prz8AMD5rbJ1zQoN6XEslK33hjzG7T1LJog=";

  buildNoDefaultFeatures = true;
  buildFeatures = ["plonk_bn254_wasm"];
  # sourceRoot = "src/crates/nargo";
  cargoBuildFlags = "--all";
  #Skip tesst due to both nix missinterpreting it's result, and it requiring a network connection.
  cargoTestFlags = "-- --skip compilation_fail --skip noir_integration";

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
    outputHashes = {
      "arkworks_backend-0.1.0" = "sha256-fpYNDZwmy8qqBob+16adKjWes0Ti9Zt+HMroKxGhY2k=";
      "barretenberg_static_lib-0.1.0" = "sha256-JhAa5NQLLioiUy6V5F4ScEW0zbP6+heLrw6erSsYmlk=";
      "barretenberg_wrapper-0.1.0" = "sha256-T4Bal9ytok5qivHg0yTxabs7ZLq0HOF3m31XBVWdf3g=";
      "chumsky-0.8.0" = "sha256-TvITrQMJlaBWx2tayYMX8AcvV4i0fyxrveBSMVojPMk=";
      "marlin_arkworks_backend-0.1.0" = "sha256-1brtVfJgK4uTpCaCamsYcDdeH1vPvMV2Rzx6mUUeJ38=";
    };
  };

  nativeBuildInputs = with pkgs; [cmake llvmPackages.llvm llvmPackages.openmp pkgconfig rust-bin.stable.latest.default];
}
