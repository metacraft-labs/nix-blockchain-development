{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "py-flags";
  version = "1.1.4";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-tqoYxz6OUybUVnkO+fXosoqPcrx2+GNqUZiN/KaQ900=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    dictionaries
  ];
}
