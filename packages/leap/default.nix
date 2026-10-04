{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pkgs,
  lib,
  xz,
}:
# leap 4.0 needs LLVM 14 (clang_14, llvm_14), which nixpkgs 25.11 removed
# together with clang14Stdenv. Until it is ported to a current LLVM it cannot
# build, so it is marked broken rather than failing every evaluation that
# reaches it.
stdenv.mkDerivation rec {
  pname = "leap";
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

  meta.broken = true;
}
