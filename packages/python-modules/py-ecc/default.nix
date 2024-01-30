{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cached-property,
  eth-typing,
  eth-utils,
  mypy-extensions,
  pytestCheckHook,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "py-ecc";
  version = "7.0.0";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "py_ecc";
    rev = "v${version}";
    sha256 = "sha256-DKe+bI1GEzXg4Y4n5OA1/hWYz9L3X1AvaOFPEnCaAfs=";
  };

  propagatedBuildInputs = [
    cached-property
    eth-typing
    eth-utils
    mypy-extensions
  ];

  checkInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = ["py_ecc"];

  meta = with lib; {
    description = "ECC pairing and bn_128 and bls12_381 curve operations";
    homepage = "https://github.com/ethereum/py_ecc";
    license = licenses.mit;
    maintainers = with maintainers; [SuperSandro2000];
  };
}
