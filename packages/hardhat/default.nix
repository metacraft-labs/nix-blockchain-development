{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  libsecret,
  python3,
  testers,
  vsce,
}:
buildNpmPackage rec {
  pname = "hardhat";
  version = "2.12.4";

  src = fetchFromGitHub {
    owner = "NomicFoundation";
    repo = "hardhat";
    rev = "hardhat@${version}";
    hash = lib.fakeSha256;
  };

  npmDepsHash = lib.fakeSha256;

  meta = with lib; {
    homepage = "https://github.com/NomicFoundation/hardhat";
    description = "Hardhat is a development environment to compile, deploy, test, and debug your Ethereum software. Get Solidity stack traces & console.log. ";
  };
}
