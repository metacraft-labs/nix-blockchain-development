{
  lib,
  python3Packages,
  eth-abi-211,
  parsimonious-081,
}:
python3Packages.buildPythonPackage rec {
  pname = "ethereum-input-decoder";
  version = "0.2.2";

  src = python3Packages.fetchPypi {
    pname = "ethereum_input_decoder";
    inherit version;
    sha256 = "sha256-jPCfIhdvgmgqJb5UfkSTDpXvJw89F99edGDWUaM8hgY=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    requests
    eth-abi-211
    parsimonious-081
  ];
}
