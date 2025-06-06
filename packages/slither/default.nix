{ lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "slither";
  version = "0.11.3";

  src = python3Packages.fetchPypi {
    pname = "slither_analyzer";
    inherit version;
    sha256 = "09953ddb89d9ab182aa5826bda6fa3da482c82b5ffa371e34b35ba766044616e";
  };

  propagatedBuildInputs = with python3Packages; [
    packaging
    prettytable
    pycryptodome
    crytic-compile
    web3
    eth-abi
    eth-typing
    eth-utils
  ];

  doCheck = false;

  meta = with lib; {
    description = "Static analysis framework for Solidity";
    homepage = "https://github.com/crytic/slither";
    license = licenses.agpl3;
    mainProgram = "slither";
    platforms = platforms.all;
  };
}
