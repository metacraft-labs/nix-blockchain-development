{
  stdenv,
  lib,
  fetchFromGitHub,
  meson,
  cmake,
  ninja,
  pkg-config,
  openssl,
  rapidjson,
  howard-hinnant-date,
  gcc12,
}:
stdenv.mkDerivation rec {
  pname = "pistache";
  version = "2023-02-25";
  src = fetchFromGitHub {
    owner = "pistacheio";
    repo = "pistache";
    rev = "ae073a0709ed1d6f0c28db90766c64b06f0366e6";
    hash = "sha256-4mqiQRL3ucXudNRvjCExPUAlz8Q5BzEqJUMVK6f30ug=";
  };

  nativeBuildInputs = [
    gcc12
    meson
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    openssl
    rapidjson
    howard-hinnant-date
  ];

  mesonFlags = lib.optional (openssl != null) (lib.mesonOption "PISTACHE_USE_SSL" "true");

  meta = {
    homepage = "https://github.com/pistacheio/pistache";
    platforms = lib.platforms.linux;
  };
}
