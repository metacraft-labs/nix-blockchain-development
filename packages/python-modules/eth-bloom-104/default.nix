{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = " eth-bloom";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-bloom";
    rev = "v${version}";
    sha256 = "sha256-I+533a+OVBThUegL9EXMQOPrYxaxiiPSwZr1CmYSn5w=";
  };

  preConfigure = ''
    substituteInPlace setup.py --replace \'setuptools-markdown\' ""
  '';

  propagatedBuildInputs = with python3Packages; [
    setuptools
    eth-hash
    pycryptodome
  ];
}
