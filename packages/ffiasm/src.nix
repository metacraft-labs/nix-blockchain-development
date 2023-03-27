{pkgs}:
with pkgs;
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

    nativeBuildInputs = with pkgs; [gtest gmp nasm];

    buildPhase = ''
      runHook preBuild
      echo "Nothing to build"
      runHook postBuild
    '';

    meta = with lib; {
      homepage = "https://github.com/iden3/ffiasm";
      platforms = with platforms; linux ++ darwin;
    };
  }
