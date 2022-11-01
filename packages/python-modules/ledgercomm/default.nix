{pkgs}:
with pkgs;
  python3Packages.buildPythonPackage rec {
    pname = "ledgercomm";
    version = "1.1.0";

    format = "wheel";
    dist = "py3";
    python = "py3";


    src = python3Packages.fetchPypi {
      inherit pname version format dist python;
    
      sha256 = "a85c16d3e2967ae6c0fa1bc9da2d99f766c166f32cd4d52a7e3537f2c849bf5f";
    };



    propagatedBuildInputs = with python3Packages; [
      cython
      hidapi
      hid
    ];
    
    meta = with lib; {
      homepage = "https://github.com/LedgerHQ/ledgercomm";
      platforms = with platforms; linux ++ darwin;
    };
  }
