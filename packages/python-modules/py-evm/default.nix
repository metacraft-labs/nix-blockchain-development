{
  lib,
  python3Packages,
  py-ecc-410,
  rlp-201,
  pyethash,
  eth-keys-034,
  eth-bloom-104,
  trie,
}:
python3Packages.buildPythonPackage rec {
  pname = "py-evm";
  version = "0.5.0a1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-NbEv1GrxmLbqPC54NAExGS3L6OMw2cYh26CTnLnckQM=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    lru-dict
    py-ecc-410
    rlp-201
    pyethash
    eth-keys-034
    eth-bloom-104
    trie
  ];

  doCheck = false;
}
