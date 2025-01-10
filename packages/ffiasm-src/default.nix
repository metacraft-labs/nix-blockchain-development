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
  version = "0.1.5";
  src = fetchFromGitHub {
    owner = "iden3";
    repo = "ffiasm-old";
    rev = "v${version}";
    hash = "sha256-HZLwzt6U8rr727MmGrH4b73isUPJ36vux0Kj7DDPHoo=";
  };

  npmDepsHash = "sha256-Tn27JihH8+15h4LAJc3NpoUs9Gnhe2rfLM5HspmxTUk=";

  npmPackFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  # doCheck = with gccStdenv.buildPlatform; !(isDarwin && isx86);
  # Tests are disabled as they require too much time.
  # TODO: Re-enable them when we figure out if we can speed them up (e.g. reduce
  # number of iterations, or run a smaller subset).
  doCheck = false;
  nativeCheckInputs = [
    nasm
    nodePackages.mocha
    gccStdenv.cc
  ];
  checkInputs = [ gmp ];
  checkPhase = "mocha --bail";

  meta = {
    mainProgram = "buildzqfield";
    homepage = "https://github.com/iden3/ffiasm";
    platforms = with lib.platforms; linux ++ darwin;
  };
}
