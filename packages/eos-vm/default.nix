{
  clangStdenv,
  nodejs,
  fetchgit,
  pkgs,
  lib,
}:
clangStdenv.mkDerivation rec {
  name = "eos-vm";
  version = "0-unstable-2025-07-30";
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
    rev = "377c046ec834750614aec33e31ec739c2443f54d";
    sha256 = "sha256-fBGY6zS1JnLRKf8T0HAnMy0Zbh25Dte/ebGwwMhj3Ro=";
  };
}
