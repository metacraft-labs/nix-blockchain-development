{
  python3Packages,
  fetchPypi,
  lib,
}:
python3Packages.buildPythonPackage {
  pname = "teatime";
  version = "0.3.1";

  src = /home/hkrasenov/code/repos/teatime;

  build-system = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  propagatedBuildInputs = with python3Packages; [loguru requests];

  doCheck = false;

  meta = with lib; {
    description = "A minimal Python tea time application";
    homepage = "https://github.com/dmuhs/teatime";
    license = licenses.mit;
  };
}
