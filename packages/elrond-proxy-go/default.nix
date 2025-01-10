{ pkgs }:
with pkgs;
buildGoModule rec {
  pname = "elrond-proxy-go";
  version = "1.1.25";

  src = fetchgit {
    url = "https://github.com/ElrondNetwork/elrond-proxy-go";
    rev = "v${version}";
    sha256 = "sha256-Rlx1DQS0JQ9MwFeYAaH5AQw5uJN7eHR1RoewPeehwYw=";
  };

  vendorHash = "sha256-Nuq8mhZ5aNOHAZlOhtKSqoKrex6kmfuaTxNFxV/TwEw=";
  modSha256 = lib.fakeSha256;

  meta = with lib; {
    description = " 🐙 Elrond Proxy: The official implementation of the web proxy for the Elrond Network. An intermediary that abstracts away the complexity of Elrond sharding, through a friendly HTTP API. ";
    homepage = "https://github.com/ElrondNetwork/elrond-proxy-go";
    license = licenses.gpl3;
  };
}
