{pkgs}:
with pkgs;
  buildNpmPackage rec {
    pname = "circom_runtime";
    version = "0.1.22";
    src = fetchFromGitHub {
      owner = "iden3";
      repo = "circom_runtime";
      rev = "v${version}";
      hash = "sha256-80aqwYuu6TQURAPYIeDhuum67yDms7pBDaiuIeMFHxU=";
    };

    npmDepsHash = "sha256-Pcenh1cdW/2r0k/XQN4aS6iX4LQRJznxzo3ngj9lDoo=";

    nativeBuildInputs = with pkgs; [gtest nodejs];

    buildInputs = with pkgs; [];

    meta = with lib; {
      homepage = "https://github.com/iden3/circom_runtime";
      platforms = with platforms; linux ++ darwin;
    };
  }
