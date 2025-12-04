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
  gcc15,

  opensslSupport ? true,
}:
stdenv.mkDerivation rec {
  pname = "pistache";
  version = "0.4.26";
  src = fetchFromGitHub {
    owner = "pistacheio";
    repo = "pistache";
    rev = "v${version}";
    hash = "sha256-x/VFig+vvDpuWvomNwO1+LSDUfk1aV7zP7KCtrCHbTg=";
  };

  nativeBuildInputs = [
    gcc15
    meson
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    rapidjson
    howard-hinnant-date
  ]
  ++ lib.optionals opensslSupport [
    openssl
  ];

  mesonFlags = [
  ]
  ++ lib.optionals opensslSupport [
    (lib.mesonOption "PISTACHE_USE_SSL" "true")
  ];

  meta = {
    homepage = "https://github.com/pistacheio/pistache";
    platforms = lib.platforms.linux;
  };
}
