{ pkgs }:
let
  version = "36.0.2"; # Also update the hash in vectors.nix
  cryptography-vectors = pkgs.callPackage ./vectors.nix { inherit pkgs; } { inherit version; };
in
with pkgs;
python3Packages.buildPythonPackage rec {
  pname = "cryptography";
  inherit version;

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-cPj097sqyfNAZVy6yJ1oxSevW7Q4dSKoQT6EHj5mKMk=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    sourceRoot = "${pname}-${version}/${cargoRoot}";
    name = "${pname}-${version}";
    sha256 = "sha256-6C4N445h4Xf2nCc9rJWpSZaNPilR9GfgbmKvNlSIFqg=";
  };

  cargoRoot = "src/rust";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs =
    with python3Packages;
    lib.optionals (!python3Packages.isPyPy) [
      cffi
    ]
    ++ [
      rustPlatform.cargoSetupHook
      setuptools-rust
    ]
    ++ (with pkgs; [
      cargo
      rustc
    ]);

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.Security
      libiconv
    ];

  propagatedBuildInputs =
    with python3Packages;
    lib.optionals (!python3Packages.isPyPy) [
      cffi
    ];

  checkInputs = with python3Packages; [
    cryptography-vectors
    hypothesis
    iso8601
    pretend
    pytestCheckHook
    pytest-subtests
    pytz
  ];

  pytestFlagsArray = [
    "--disable-pytest-warnings"
  ];

  disabledTestPaths = lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [
    # aarch64-darwin forbids W+X memory, but this tests depends on it:
    # * https://cffi.readthedocs.io/en/latest/using.html#callbacks
    "--ignore=tests/hazmat/backends/test_openssl_memleak.py"
  ];

  meta = with lib; {
    description = "A package which provides cryptographic recipes and primitives";
    longDescription = ''
      Cryptography includes both high level recipes and low level interfaces to
      common cryptographic algorithms such as symmetric ciphers, message
      digests, and key derivation functions.
      Our goal is for it to be your "cryptographic standard library". It
      supports Python 2.7, Python 3.5+, and PyPy 5.4+.
    '';
    homepage = "https://github.com/pyca/cryptography";
    changelog =
      "https://cryptography.io/en/latest/changelog/#v" + replaceStrings [ "." ] [ "-" ] version;
    license = with licenses; [
      asl20
      bsd3
      psfl
    ];
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
