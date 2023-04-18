{
  lib,
  pkgs,
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
  ethereum-input-decoder,
  rlp-201,
  eth-account-059,
  pre-commit-2200,
  cytoolz-0112,
  py-evm,
  z3-solver,
  persistent_fixed,
  matplotlib_fixed,
  pytest_fixed,
  pytest-cov_fixed,
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
    #removing version specification, as for some reason nix has trouble finding them, even when they match the version specification
    substituteInPlace requirements.txt --replace "cytoolz<0.12.0" cytoolz
    substituteInPlace requirements.txt --replace "pyparsing<3,>=2.0.2" pyparsing
    substituteInPlace requirements.txt --replace "coverage<7.0,>6.0" coverage
    #the closest nix has is 4.8.5
    substituteInPlace requirements.txt --replace "z3-solver>=4.8.8.0" z3-solver
  '';

  propagatedBuildInputs = with pkgs;
  with python3Packages; [
    setuptools
    pytest-mock
    requests
    semantic-version
    transaction
    certifi
    coincurve
    configparser
    coloredlogs
    cython
    gcc

    #custom packages
    pyparsing-247
    py-ecc-410
    eth-typing-230
    eth-utils-110
    eth-keyfile-051
    eth-keys-034
    eth-abi-211
    parsimonious-081
    py-solc-x
    typing-extensions-31002
    blake2b-py
    markupsafe-201
    coverage-650
    py-flags
    ethereum-input-decoder
    rlp-201
    eth-account-059
    pre-commit-2200
    cytoolz-0112
    py-evm
    z3-solver
    persistent_fixed
    matplotlib_fixed
    pytest_fixed
    pytest-cov_fixed
  ];
  nativeBuildInputs = propagatedBuildInputs;

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
