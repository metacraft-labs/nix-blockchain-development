{
  clangStdenv,
  nodejs,
  fetchFromGitHub,
  pkgs,
  lib,
  xz,
}:
clangStdenv.mkDerivation rec {
  name = "leap";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "AntelopeIO";
    repo = "leap";
    rev = "v${version}";
    hash = "sha256-d9VjRfm+L7y8weADFnj9svm7go6HDyCKIsYsVuzUyZ4=";
    fetchSubmodules = true;
  };

  prePatch = ''
    find . -type f -name '*.py' -print0 | xargs -0 -I{} sed -i -E 's#/usr/bin/env python3?#${pkgs.python3}/bin/python3#' {}
  '';

  nativeBuildInputs = with pkgs; [pkgconfig cmake clang git python3];

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
}
