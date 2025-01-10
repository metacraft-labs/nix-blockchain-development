{
  clangStdenv,
  nodejs,
  fetchgit,
  pkgs,
  lib,
}:
clangStdenv.mkDerivation rec {
  name = "eos-vm";
  version = "1.0.0-rc1";
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
    rev = "329db27d888dce32c96b4f209cdea45f1d07e5e7";
    sha256 = "sha256-uRNj/iOt6cuGZcdQrYjYO3qyu6RBNQh+uT2AAmPoH14=";
  };
}
