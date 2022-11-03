{pkgs}:
with pkgs;
pkgs.stdenv.mkDerivation rec {
  name = "mcl-${version}";
  version = "1.74";

  src = fetchgit {
    url = "https://github.com/herumi/mcl";
    rev = "v${version}";
    sha256 = "sha256-Ht+/2AIMb1+ilysNp/zm9Qxb5AI17xTPEh0nVdJNxyM=";
  };

  nativeBuildInputs = [cmake gmp];

  meta = with pkgs.lib; {
    homepage = "https://github.com/herumi/mcl";
    platforms = with platforms; linux ++ darwin;
  };
}
