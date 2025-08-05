{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "eradicate2";
  version = "unstable-2025-08-05";

  src = fetchFromGitHub {
    owner = "blocksense-network";
    repo = "ERADICATE2";
    rev = "da291e6d51182ffa22965e3f2316bda28212861c";
    hash = "sha256-JnLwXCNvagc3AVPp9Ro7DuecnHxyBoLgAm47+uuK86I=";
  };

  installPhase = ''
    install -Dm 755 ./build/eradicate2 $out/bin/eradicate2
  '';

  meta = with lib; {
    description = "Vanity address generator for CREATE3 addresses";
    homepage = "https://github.com/1inch/ERADICATE3";
    license = licenses.unfree;
    mainProgram = "eradicate2";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
