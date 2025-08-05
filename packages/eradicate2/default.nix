{
  lib,
  stdenv,
  fetchFromGitHub,
  opencl-headers,
  ocl-icd,
}:

stdenv.mkDerivation rec {
  pname = "eradicate2";
  version = "unstable-2025-08-05";

  src = fetchFromGitHub {
    owner = "blocksense-network";
    repo = "ERADICATE2";
    rev = "3f22332b81f36ef021b016b1b54e8540db3fdc91";
    hash = "sha256-A38nAtQfyxFPmxiojnoj6xOnfWK+FHKucYDuP/7/tjQ=";
  };

  buildInputs = lib.optionals stdenv.isLinux [
    opencl-headers
    ocl-icd
  ];

  postPatch = ''
    patchShebangs --build ./embed-in-cpp.sh
  '';

  installPhase = ''
    install -Dm 755 ./build/eradicate2 $out/bin/eradicate2
  '';

  meta = with lib; {
    description = "Vanity address generator for CREATE2 addresses";
    homepage = "https://github.com/blocksense-network/ERADICATE2";
    license = licenses.unfree;
    mainProgram = "eradicate2";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
