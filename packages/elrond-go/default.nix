{ pkgs }:
with pkgs;
buildGoModule rec {
  pname = "elrond-go";
  version = "1.3.48";

  src = fetchgit {
    url = "https://github.com/ElrondNetwork/elrond-go";
    rev = "v${version}";
    hash = "sha256-OUUCJqbjAGVI7VxXfBYj5ccqWXtadblqpucE9xBv9NI=";
  };

  vendorSha256 = "sha256-0siC4G2+FUeLN8uLLHBU4EN9WL7TuywEbf6leJgyJpg=";
  modSha256 = lib.fakeSha256;

  subPackages = [ "cmd/node" ];

  patches = [ ./go.mod.patch ];

  nativeBuildInputs = [ metacraft-labs.mcl metacraft-labs.bls ];

  CGO_CFLAGS = "-I${metacraft-labs.mcl}/include -I${metacraft-labs.bls}/include";


  meta = with lib; {
    description = "Elrond-GO: The official implementation of the Elrond protocol, written in golang. ";
    homepage = "https://github.com/ElrondNetwork/elrond-go";
    license = licenses.gpl3;
  };
}
