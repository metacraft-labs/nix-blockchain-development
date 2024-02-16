{
  pkgs,
  minimalPkgs,
}: let
in
  with pkgs;
    minimalPkgs.stdenv.mkDerivation rec {
      pname = "ci-matrix";
      version = "N/A";

      src = ../../scripts;

      buildInputs = [minimalPkgs.bash minimalPkgs.glibc];

      buildPhase = ''
        cp $src/{ci-matrix,nix-eval-jobs,system-info}.sh .
        sed -i 's|jq|${minimalPkgs.jq}/bin/jq|' *.sh
        sed -i 's|nix-eval-jobs |${minimalPkgs.nix-eval-jobs}/bin/nix-eval-jobs |' *.sh
        sed -i 's|"$root_dir/scripts/|"'$out'/bin/|' *.sh
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp {ci-matrix,nix-eval-jobs,system-info}.sh $out/bin'';

      postFixup = ''
        sed -i 's|${pkgs.bash}|${bash}|' $out/bin/*
      '';

      doCheck = false;

      passthru = {
        jq = minimalPkgs.jq;
        nix-eval-jobs = minimalPkgs.nix-eval-jobs;
        nix = minimalPkgs.nix;
      };

      meta.mainProgram = "ci-matrix.sh";
    }
