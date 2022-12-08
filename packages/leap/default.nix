{
  stdenv,
  nodejs,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  name = "leap";
  version = "3.2.0";
  buildInputs = [gcc];
  src = fetchFromGitHub {
    owner = "AntelopeIO";
    repo = "leap";
    rev = "v${version}";
    sha256 = lib.fakeSha256;
  };
}
