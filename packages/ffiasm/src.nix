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

  # doCheck = with gccStdenv.buildPlatform; !(isDarwin && isx86);
  # Tests are disabled as they require too much time.
  # TODO: Re-enable them when we figure out if we can speed them up (e.g. reduce
  # number of iterations, or run a smaller subset).
  doCheck = false;
  nativeCheckInputs = [nasm nodePackages.mocha gccStdenv.cc];
  checkInputs = [gmp];
  checkPhase = "mocha --bail";

  meta = {
    mainProgram = "buildzqfield";
    homepage = "https://github.com/iden3/ffiasm";
    platforms = with lib.platforms; linux ++ darwin;
  };
}
