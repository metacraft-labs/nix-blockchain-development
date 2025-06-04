{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "cdt";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "AntelopeIO";
    repo = "cdt";
    rev = "v${version}";
    hash = "sha256-+s+W2MBc/G2SCuBOdxdq661h5Oz1IH3z3HosrOQAbYU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    git
    python3
  ];

  meta = {
    description = "Contract Development Toolkit (CDT) is a suite of tools to facilitate C/C++ development of contracts for Antelope blockchains";
    homepage = "https://github.com/AntelopeIO/cdt";
    license = lib.licenses.mit;
    mainProgram = "cdt";
    platforms = lib.platforms.all;
  };
}
