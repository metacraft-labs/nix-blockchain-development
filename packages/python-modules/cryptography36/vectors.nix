{ pkgs }:
{ version }:
with pkgs;
python3Packages.buildPythonPackage rec {
  pname = "cryptography-vectors";
  inherit version;

  src = python3Packages.fetchPypi {
    pname = "cryptography_vectors";
    inherit version;
    sha256 = "sha256-KnkkRJoDAl+vf4dUpvQgAAHKshBzSmzmrB9r2s06aOQ=";
  };

  # No tests included
  doCheck = false;

  pythonImportsCheck = [ "cryptography_vectors" ];

  meta = with lib; {
    description = "Test vectors for the cryptography package";
    homepage = "https://cryptography.io/en/latest/development/test-vectors/";
    # Source: https://github.com/pyca/cryptography/tree/master/vectors;
    license = with licenses; [
      asl20
      bsd3
    ];
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
