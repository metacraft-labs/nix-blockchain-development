{pkgs}:
pkgs.clangStdenv.mkDerivation rec {
  name = "zkllvm-${version}";
  version = "0.0.32";

  src = fetchgit {
    url = "https://github.com/nilfoundation/zkllvm";
    sha256 = lib.fakeSha256;
    rev = "v${version}";
  };

  buildInputs = [cmake boost.dev openssl.dev];

  meta = with pkgs.lib; {
    homepage = "https://github.com/nilfoundation/zkllvm";
    platforms = with platforms; linux ++ darwin;
  };
}
