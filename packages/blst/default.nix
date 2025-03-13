{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "blst";
  version = "0.3.14";

  src = fetchFromGitHub {
    owner = "supranational";
    repo = "blst";
    rev = "v${version}";
    hash = "sha256-IlbNMLBjs/dvGogcdbWQIL+3qwy7EXJbIDpo4xBd4bY=";
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
