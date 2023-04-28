{
  lib,
  python3Packages,
  typing-extensions-31002,
  eth-utils-110,
  rlp-201,
  hexbytes-023,
}:
python3Packages.buildPythonPackage rec {
  pname = "trie";
  version = "2.0.0a5";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-Y4X1QWWlfpluDdvjruaHeDVL5YzKGzYj6KmhpWaAxFs=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    sortedcontainers
    hexbytes-023
    typing-extensions-31002
    eth-utils-110
    rlp-201
  ];
}
