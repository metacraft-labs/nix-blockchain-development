{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodePackages,
  nasm,
  gmp,
  gccStdenv,
}:
buildNpmPackage rec {
  pname = "ffiasm-src";
  version = "0.1.4";
  src = fetchFromGitHub {
    owner = "iden3";
    repo = "ffiasm";
    rev = "v${version}";
    hash = "sha256-nwDJi9HWCdhfUD3Os8MzngQq7SH6gx52vp77UwS2DLw=";
  };

  npmDepsHash = "sha256-xWXEcNDkIZhDjm5h6yweGkVjbo3mWKezg3wfTCkiOEE=";

  npmPackFlags = ["--ignore-scripts"];

  dontNpmBuild = true;

  doCheck = true;
  nativeCheckInputs = [nasm nodePackages.mocha gccStdenv.cc];
  checkInputs = [gmp];
  checkPhase = "mocha --bail";

  meta = {
    mainProgram = "buildzqfield";
    homepage = "https://github.com/iden3/ffiasm";
    platforms = with lib.platforms; linux ++ darwin;
  };
}
