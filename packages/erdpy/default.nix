{pkgs}:
with pkgs;
  python3Packages.buildPythonApplication rec {
    pname = "erdpy";
    version = "2.0.3";

    format = "wheel";
    dist = "py3";
    python = "py3";


    src = python3Packages.fetchPypi {
      inherit pname version format dist python;
    
      sha256 = "215edfb6f9f8c8214cc42e67e8d5328859486007ac4e3438cb9aabd21de67414";
    };


  postPatch = ''
    
    chmod u+rwx -R ./dist
    pushd dist
    wheel unpack --dest unpacked ./*.whl
    pushd unpacked/erdpy-${version}/erdpy-2.0.3.dist-info

    # ledgercomm[hid] isn't a supported syntax by nix, so we split them into seperate requirements
    sed -iE 's/Requires-Dist: ledgercomm.*/Requires-Dist: ledgercomm\nRequires-Dist: hid/' METADATA
    
    # # cryptography 36.0.2
    # sed -iE 's/Requires-Dist: cryptography.*/Requires-Dist: cryptography/' METADATA
    # cat METADATA
    popd
    wheel pack ./unpacked/erdpy-${version}
    popd
  '';

    propagatedBuildInputs = with python3Packages; [
      hid
    ];

    meta = with lib; {
      homepage = "https://github.com/ElrondNetwork/elrond-sdk-erdpy";
      platforms = with platforms; linux ++ darwin;
    };
  }
