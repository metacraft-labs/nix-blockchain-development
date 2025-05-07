{
  clangStdenv,
  nodejs,
  fetchFromGitHub,
  pkgs,
  lib,
}:
clangStdenv.mkDerivation rec {
  name = "cdt";
  version = "4.1.0";
  buildInputs = with pkgs; [
    llvm
    curl.dev
    gmp.dev
    openssl.dev
    libusb1.dev
    bzip2.dev
    (boost.override {
      enableShared = false;
      enabledStatic = true;
    })
  ];
  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
    clang
    git
    python3
  ];

  src = fetchFromGitHub {
    owner = "AntelopeIO";
    repo = "cdt";
    rev = "v${version}";
    hash = "sha256-+s+W2MBc/G2SCuBOdxdq661h5Oz1IH3z3HosrOQAbYU=";
    fetchSubmodules = true;
  };
}
