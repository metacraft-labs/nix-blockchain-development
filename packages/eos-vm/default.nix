{
  clangStdenv,
  nodejs,
  fetchgit,
  pkgs,
  lib,
}:
clangStdenv.mkDerivation rec {
  name = "eos-vm";
  version = "0-unstable-2025-03-05";
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
    url = "https://github.com/AntelopeIO/eos-vm";
    rev = "e8b4e8b799b9d6e3993e16e7c4a5d2fe04c739b6";
    sha256 = "sha256-UZMuDMFlEVtylKe2E+T046S3lWp9SlzbvHnyW+UxPP0=";
  };
}
