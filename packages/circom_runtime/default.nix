{ pkgs }:
with pkgs;
buildNpmPackage rec {
  pname = "circom_runtime";
  version = "0.1.24";
  src = fetchFromGitHub {
    owner = "iden3";
    repo = "circom_runtime";
    rev = "v${version}";
    hash = "sha256-iC6kqVn1ixJlcuf+t2wbC+0/sCcXGvSRfuheLiW0Egs=";
  };

  npmDepsHash = "sha256-LvgKNazeoS7FcsjFDHnA9ZLePOesFu6eeEWDRGQRPLE=";

  nativeBuildInputs = with pkgs; [
    gtest
    nodejs
  ];

  buildInputs = with pkgs; [ ];

  meta = with lib; {
    homepage = "https://github.com/iden3/circom_runtime";
    platforms = with platforms; linux ++ darwin;
  };
}
