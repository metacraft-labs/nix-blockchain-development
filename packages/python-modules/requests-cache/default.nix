{pkgs}:
with pkgs;
  python3Packages.buildPythonPackage rec {
    pname = "requests_cache";
    version = "0.9.7";

    format = "wheel";
    dist = "py3";
    python = "py3";

    src = python3Packages.fetchPypi {
      inherit pname version format dist python;
    
      sha256 = "3f57badcd8406ecda7f8eaa8145afd0b180c5ae4ff05165a2c4d40f3dc88a6e5";
    };


    propagatedBuildInputs = with python3Packages; [
      metacraft-labs.cattrs22-2
    ];

    meta = with lib; {
      homepage = "https://github.com/requests-cache/requests-cache";
      platforms = with platforms; linux ++ darwin;
    };
  }
