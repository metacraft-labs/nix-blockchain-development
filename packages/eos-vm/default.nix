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
    (boost.override
      {
        enableShared = false;
        enabledStatic = true;
      })
  ];
  nativeBuildInputs = with pkgs; [pkgconfig cmake clang git python3];

  prePatch = ''
  '';

  src = fetchgit {
    url = "https://github.com/AntelopeIO/eos-vm";
    sha256 = "sha256-AQ8VsbP/14E/6gr1WNNCJJkpoiAe4liPfE9057fn5lc=";
  };
}
