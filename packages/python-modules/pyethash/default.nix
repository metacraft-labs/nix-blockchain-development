{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "pyethash";
  version = "0.1.27";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-/2YxnOJrnXffH2EJQmNNrJdC4hbywnsFHAosLeycKBg=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
  ];
}
