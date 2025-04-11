{ pkgs }:
with pkgs;
buildNpmPackage rec {
  pname = "circom_runtime";
  version = "0.1.28";
  src = fetchFromGitHub {
    owner = "iden3";
    repo = "circom_runtime";
    rev = "v${version}";
    hash = "sha256-iC34UChMczv3lPUNY+coHEBNMnzgegFr6KqDz9A8+24=";
  };

  npmDepsHash = "sha256-GES/K/znDMpvm4B63R5ryEI/tYlLWcwlBwFAzBnawko=";

  nativeBuildInputs = with pkgs; [
    gtest
    nodejs
  ];

  buildInputs = with pkgs; [ ];

  meta = with lib; {
    homepage = "https://github.com/iden3/circom_runtime";
    platforms = with platforms; linux ++ darwin;
  };
}
