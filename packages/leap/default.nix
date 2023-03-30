{
  clangStdenv,
  nodejs,
  fetchgit,
  pkgs,
  lib,
  xz,
}:
clangStdenv.mkDerivation rec {
  name = "leap";
  version = "3.2.0";
  buildInputs = with pkgs; [
    llvm
    curl.dev
    gmp.dev
    openssl.dev
    libusb1.dev
    bzip2.dev
    (lib.getLib xz)
    (boost.override
      {
        enableShared = false;
        enabledStatic = true;
      })
  ];
  nativeBuildInputs = with pkgs; [pkgconfig cmake clang git python3];

  prePatch = ''
    sed -i 's#/usr/bin/env python3#${pkgs.python3}/bin/python3#' **/*.py
  '';

  src = fetchgit {
    url = "https://github.com/AntelopeIO/leap";
    rev = "v${version}";
    sha256 = "sha256-AQ8VsbP/14E/6gr1WNNCJJkpoiAe4liPfE9057fn5lc=";
  };
}
