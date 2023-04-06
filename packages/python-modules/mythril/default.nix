{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  py-ecc-410,
  eth-utils-110,
  eth-keyfile-051,
  eth-keys-034,
  eth-typing-230,
  eth-abi-211,
  parsimonious-081,
  py-solc-x,
  typing-extensions-31002,
  pyparsing-247,
  blake2b-py,
  markupsafe-201,
  coverage-650,
  py-flags,
}:
python3Packages.buildPythonPackage rec {
  pname = "mythril";
  version = "0.23.17";
  format = "setuptools";

  disabled = python3Packages.pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "ConsenSys";
    repo = "mythril";
    rev = "v${version}";
    hash = "sha256-lzxAhaQfiGygxI98x1hWP8wrHVbf9DuZuEnjJcKMRCo=";
  };

  preConfigure = ''
    substituteInPlace requirements.txt --replace py-solc py-solc-x
    substituteInPlace requirements.txt --replace py-solc-x-x ""
  '';

  nativeBuildInputs = [
  ];

  propagatedBuildInputs = with python3Packages; [
    setuptools
    pytest
    pytest-cov
    pytest-mock
    requests
    rlp
    semantic-version
    transaction
    z3
    matplotlib
    certifi
    coincurve
    #custom packages
    py-ecc-410
    eth-typing-230
    eth-utils-110
    eth-keyfile-051
    eth-keys-034
    eth-abi-211
    parsimonious-081
    py-solc-x
    typing-extensions-31002
    pyparsing-247
    blake2b-py
    markupsafe-201
    coverage-650
    py-flags
  ];

  # postFixup = lib.optionalString withSolc ''
  #   wrapProgram $out/bin/myhtril \
  #     --prefix PATH : "${lib.makeBinPath [solc]}"
  # '';

  # No Python tests
  doCheck = false;

  meta = with lib; {
    description = "Security analysis tool for EVM bytecode.";
    longDescription = ''
      Mythril is a security analysis tool for EVM bytecode. It detects security vulnerabilities in smart contracts built
      for Ethereum, Hedera, Quorum, Vechain, Roostock, Tron and other EVM-compatible blockchains. It uses
      symbolic execution, SMT solving and taint analysis to detect a variety of security vulnerabilities. It's also used
      (in combination with other tools and techniques) in the MythX security analysis platform.
    '';
    homepage = "https://github.com/ConsenSys/mythril";
    license = licenses.mit;
  };
}
