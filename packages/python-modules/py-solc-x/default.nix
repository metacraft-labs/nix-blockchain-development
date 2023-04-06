{
  lib,
  python3Packages,
  pandoc,
}:
python3Packages.buildPythonPackage rec {
  pname = "py-solc-x";
  version = "1.1.1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-2LC9KwT0fP9ukhgXOdnpTkGy1i8FaQB2HHl/pbq8drY=";
  };

  preConfigure = ''
    substituteInPlace setup.py --replace \"setuptools-markdown\" ""
  '';

  propagatedBuildInputs = with python3Packages; [
    pandoc
    setuptools
    requests
    semantic-version
  ];

  doCheck = false;

  meta = with lib; {
    homepage = https://github.com/ApeWorX/py-solc-x;
    description = "List processing tools and functional utilities";
    license = licenses.bsd3;
  };
}
