{
  lib,
  pkgs,
  python3Packages,
  jinja2_fixed,
}:
python3Packages.buildPythonPackage rec {
  pname = "z3-solver";
  version = "4.8.5.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-8naAICUcmPspvmjAWxySaUtgHea0uDUZSS5WutuF7mI=";
  };

  propagatedBuildInputs = with python3Packages; [setuptools jinja2_fixed];

  setupPyBuildFlags = [
    "--plat-name x86_64-linux"
  ];

  # tests require other angr related components
  doCheck = false;
}
