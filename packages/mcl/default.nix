{pkgs}:
with pkgs;
pkgs.stdenv.mkDerivation rec {
  name = "mcl-${version}";
  version = "1.74";

  src = fetchgit {
    url = "https://github.com/herumi/mcl";
    rev = "v${version}";
    hash = lib.fakeSha256;
  };

  nativeBuildInputs = [];

  meta = with pkgs.lib; {
    homepage = "https://github.com/herumi/mcl";
    platforms = with platforms; linux ++ darwin;
  };
}
