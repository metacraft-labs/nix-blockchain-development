{
  lib,
  python3Packages,
  fetchFromGitHub,
  maturin,
  gnumake,
  git,
  cargo,
  rustPlatform,
}:
python3Packages.buildPythonPackage rec {
  pname = "blake2b-py";
  version = "0.2.0";
  format = "gnumake";

  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "blake2b-py";
    rev = "v${version}";
    hash = "sha256-N5xnJf5MjJ+rNeeE0/B5ChHxgr8uxahV0bwHpP03LYw=";
  };

  postUnpack = ''
    cp ${./Cargo.lock} ./source/Cargo.lock
  '';

  # cargoLock = let
  #   fixupLockFile = path: (builtins.readFile path);
  # in {
  #   lockFileContents = fixupLockFile ./Cargo.lock;
  # };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    sourceRoot = "source";
    name = "${pname}-${version}";
    sha256 = "sha256-BS3zqdCn7E/alj+rw23QKasTKiQuUdtDSuyNvB/wObI=";
    postUnpack = ''
      cp ${./Cargo.lock} ./source/Cargo.lock
    '';
  };

  nativeBuildInputs = [
    maturin
    gnumake
    git
    python3Packages.python
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    python3Packages.setuptools-rust
  ];

  meta = with lib; {
    description = "Blake2b hashing in Rust with Python bindings.";
    homepage = "https://pypi.org/project/blake2b-py/";
    license = licenses.mit;
  };
}
