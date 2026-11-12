{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "blst";
  version = "0.3.17";

  src = fetchFromGitHub {
    owner = "supranational";
    repo = "blst";
    rev = "v${version}";
    hash = "sha256-ROBlbVCiXgZsP694YjjzHzoFiGY+gtfz9fP5exzxEDA=";
  };

  builder = ./builder.sh;

  meta = {
    description = "Multilingual BLS12-381 signature library";
    homepage = "https://github.com/supranational/blst";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
