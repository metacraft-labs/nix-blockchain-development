{
  lib,
  fetchgit,
  stdenv,
  pkgs,
}:
stdenv.mkDerivation rec {
  pname = "zokrates";
  version = "0.8.4";

  src = fetchgit {
    url = "https://github.com/Zokrates/ZoKrates.git";
    rev = "v${version}";
    sha256 = "sha256-DFfY6FVKvajqbS28xCvRh/Hf+Qi1cx2XZ34gboZG9XE=";
  };

  nativeBuildInputs = with pkgs; [];
  buildInputs = with pkgs; [];
}
