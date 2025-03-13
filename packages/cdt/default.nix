{
  clangStdenv,
  nodejs,
  fetchgit,
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

  src = fetchgit {
    url = "https://github.com/AntelopeIO/cdt";
    rev = "v${version}";
    sha256 = "sha256-+s+W2MBc/G2SCuBOdxdq661h5Oz1IH3z3HosrOQAbYU=";
  };
}
