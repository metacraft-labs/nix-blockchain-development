{pkgs}:
with pkgs;
pkgs.stdenv.mkDerivation rec {
  name = "bls-${version}";
  version = "1.30.0";

  src = fetchgit {
    url = "https://github.com/herumi/bls";
    rev = "v${version}";
    sha256 = lib.fakeSha256;
  };

  nativeBuildInputs = [cmake];

  meta = with pkgs.lib; {
    homepage = "https://github.com/herumi/bls";
    platforms = with platforms; linux ++ darwin;
  };
}
