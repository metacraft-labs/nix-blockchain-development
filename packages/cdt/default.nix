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
  version = "5.0.0-dev1.1";

  src = fetchFromGitHub {
    owner = "AntelopeIO";
    repo = "cdt";
    rev = "v${version}";
    hash = "sha256-i/DxKqcJhVPm2c4mjTuOeTrH62uRscSQfe7iM1Hwu8Y=";
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
    broken = true;
  };
}
