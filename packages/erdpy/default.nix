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
      popd
      pushd unpacked/erdpy-${version}

      sed -iE 's#./node#${metacraft-labs.elrond-go}/bin/node#' erdpy/testnet/core.py
      sed -iE 's#./seednode#${metacraft-labs.elrond-go}/bin/seednode#' erdpy/testnet/core.py
      sed -iE 's#./proxy#${metacraft-labs.elrond-proxy-go}/bin/proxy#' erdpy/testnet/core.py

      # Attempting to preveent erdpy from downloading elrond-go and elrond-proxy-go doeesn't work out, due to the way dependeency resolution works in erdpy
      # sed -iE 's/StandaloneModule(key="elrond_go", repo_name="elrond-go", organisation="ElrondNetwork"),//' erdpy/dependencies/install.py
      # sed -iE 's/StandaloneModule(key="elrond_proxy_go", repo_name="elrond-proxy-go", organisation="ElrondNetwork"),//' erdpy/dependencies/install.py
      # sed -iE 's/GolangModule(key="golang"),//' erdpy/dependencies/install.py

      sed -iE 's/myprocess.run_process(['go', 'build'], cwd=seednode_folder, env=golang_env)//' erdpy/testnet/setup.py
      sed -iE 's/myprocess.run_process(['go', 'build'], cwd=node_folder, env=golang_env)//' erdpy/testnet/setup.py
      sed -iE 's/myprocess.run_process(['go', 'build'], cwd=proxy_foldeer, env=golang_env)//' erdpy/testnet/setup.py




      sed -iE 's#DEPENDENCY_KEYS = ["elrond_go", "elrond_proxy_go", "testwallets"]#$DEPENDENCY_KEYS = ["testwallets"]#' erdpy/testnet/setup.py

      # sed -iE 's#{ELRONDSDK}/elrond_go/{TAG}/elrond-go-{NOvTAG}#${metacraft-labs.elrond-go}#' erdpy/testnet/setup.py
      # sed -iE 's#{ELRONDSDK}/elrond_proxy_go/{TAG}/elrond-proxy-go-{NOvTAG}#${metacraft-labs.elrond-proxy-go}#' erdpy/testnet/setup.py

      popd
      wheel pack ./unpacked/erdpy-${version}
      popd
    '';

    propagatedBuildInputs = with python3Packages; [
      hid
      metacraft-labs.cryptography36
      metacraft-labs.ledgercomm
      metacraft-labs.requests-cache
    ];

    erdpy_script = writeScriptBin "erdpy" ''
      #!/usr/bin/env python3
      # -*- coding: utf-8 -*-
      import re
      import sys
      from erdpy.cli import main
      if __name__ == '__main__':
          sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$\', \'\', sys.argv[0])
          sys.exit(main())
    '';

    meta = with lib; {
      homepage = "https://github.com/ElrondNetwork/elrond-sdk-erdpy";
      platforms = with platforms; linux ++ darwin;
    };
  }
