{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  py-ecc-410,
  eth-utils-110,
  eth-keyfile-051,
  eth-typing-230,
}:
python3Packages.buildPythonPackage rec {
  pname = "mythril";
  version = "0.23.17";
  format = "setuptools";

  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "ConsenSys";
    repo = "mythril";
    rev = "v${version}";
    hash = "sha256-lzxAhaQfiGygxI98x1hWP8wrHVbf9DuZuEnjJcKMRCo=";
  };

  nativeBuildInputs = [
  ];

  propagatedBuildInputs = with python3Packages; [
    py-ecc-410
    eth-typing-230
    eth-utils-110
    eth-keyfile-051
    setuptools
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
