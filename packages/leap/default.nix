{
  clang14Stdenv,
  nodejs,
  fetchFromGitHub,
  pkgs,
  lib,
  xz,
}:
clang14Stdenv.mkDerivation rec {
  pname = "leap";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "AntelopeIO";
    repo = "leap";
    rev = "v${version}";
    hash = "sha256-SKlHXz27H9P2Xwk9OEKak+tQ2MkT34sQZ/qpmEV8gl4=";
    fetchSubmodules = true;
  };

  prePatch = ''
    find . -type f -name '*.py' -print0 | xargs -0 -I{} sed -i -E 's#/usr/bin/env python3?#${pkgs.python3}/bin/python3#' {}
  '';

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
    clang_14
    git
    python3
  ];

  buildInputs = with pkgs; [
    llvm_14
    curl.dev
    gmp.dev
    openssl.dev
    libusb1.dev
    bzip2.dev
    (lib.getLib xz)
    (boost.override {
      enableShared = false;
      enabledStatic = true;
    })
  ];
}
