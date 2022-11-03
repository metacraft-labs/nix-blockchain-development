{pkgs}:
with pkgs;
buildGoModule rec {
  pname = "elrond-go";
  version = "1.3.48";

  src = fetchgit {
    url = "https://github.com/ElrondNetwork/elrond-go";
    rev = "v${version}";
    hash = "sha256-OUUCJqbjAGVI7VxXfBYj5ccqWXtadblqpucE9xBv9NI=";
  };

  # vendorSha256 = "sha256-YlYjlXg+jrWg73RJESAW0/RXdBReLzigeAw0YwAn1FA=";
  vendorSha256 = "sha256-0siC4G2+FUeLN8uLLHBU4EN9WL7TuywEbf6leJgyJpg=";
  modSha256 = lib.fakeSha256;
  # vendorSha256 = lib.fakeSha256;

  subPackages = ["cmd/node"];

  # postPatch = ''
  #   sed -iE 's/go 1.15/go 1.18/' go.mod
  # '';
  patches = [./go.mod.patch];

  nativeBuildInputs = [metacraft-labs.mcl];

  meta = with lib; {
    description = "Elrond-GO: The official implementation of the Elrond protocol, written in golang. ";
    homepage = "https://github.com/ElrondNetwork/elrond-go";
    license = licenses.gpl3;
  };
}