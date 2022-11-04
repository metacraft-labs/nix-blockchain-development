{pkgs}:
with pkgs;
pkgs.stdenv.mkDerivation rec {
  name = "bls-${version}";
  version = "1.30.0";

  src = fetchgit {
    url = "https://github.com/herumi/bls";
    rev = "v${version}";
    sha256 = "sha256-9wdpLhcj6J92jyS/ZAr/tdjr4qvg58oXUH7iT7upYDk=";
  };

  nativeBuildInputs = [cmake gmp];

  meta = with pkgs.lib; {
    homepage = "https://github.com/herumi/bls";
    platforms = with platforms; linux ++ darwin;
  };
}
