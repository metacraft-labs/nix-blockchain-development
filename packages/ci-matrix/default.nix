{pkgs}: let
  jq = (pkgs.jq.override {onigurumaSupport = false;}).overrideAttrs (oldAttrs: {
    # outputs = ["bin" "doc" "man" "dev" "lib" "out"];
    outputs = ["bin" "dev" "lib" "out"];
    configureFlags = oldAttrs.configureFlags ++ ["--mandir=/tmp" "--datadir=/tmp"];
  });
  nix-eval-jobs = pkgs.nix-eval-jobs;
in
  with pkgs;
    stdenv.mkDerivation rec {
      pname = "ci-matrix";
      version = "N/A";

      src = ../../scripts;

      buildPhase = ''
        cp $src/{ci-matrix,nix-eval-jobs,system-info}.sh .
        sed -i 's|jq|${jq}/bin/jq|' *.sh
        sed -i 's|nix-eval-jobs |${nix-eval-jobs}/bin/nix-eval-jobs |' *.sh
        sed -i 's|"$root_dir/scripts/|"'$out'/bin/|' *.sh
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp {ci-matrix,nix-eval-jobs,system-info}.sh $out/bin'';

      doCheck = false;

      meta.mainProgram = "ci-matrix.sh";
    }
