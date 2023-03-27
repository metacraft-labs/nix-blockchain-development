{pkgs}:
with pkgs;
  stdenv.mkDerivation rec {
    name = "pistache-${version}";
    version = "2023-02-25";
    src = fetchFromGitHub {
      owner = "pistacheio";
      repo = "pistache";
      rev = "ae073a0709ed1d6f0c28db90766c64b06f0366e6";
      hash = "sha256-4mqiQRL3ucXudNRvjCExPUAlz8Q5BzEqJUMVK6f30ug=";
    };

    nativeBuildInputs = with pkgs; [meson cmake ninja pkgconfig gtest];

    buildInputs = with pkgs; [
      doxygen
      openssl
      rapidjson
      howard-hinnant-date
    ];

    meta = with lib; {
      homepage = "https://github.com/pistacheio/pistache";
      platforms = with platforms; linux ++ darwin;
    };
  }
