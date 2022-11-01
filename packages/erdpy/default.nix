{pkgs}:
with pkgs;
  python39Packages.buildPythonPackage rec {
    pname = "erdpy";
    version = "2.0.3";
    src = python39Packages.fetchPypi {
      inherit pname version;
      sha256 = "08fdd5ef7c96480ad11c12d472de21acd32359996f69a5259299b540feba4560";
  };

    format = "setuptools";

    meta = with lib; {
      homepage = "https://github.com/ElrondNetwork/elrond-sdk-erdpy";
      platforms = with platforms; linux ++ darwin;
    };
  }
