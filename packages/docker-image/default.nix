{
  pkgs,
  dockerTools,
  cacert,
  ci-matrix,
  minimalPkgs,
  replaceDependency,
}: let
  image = (dockerTools.override {jq = minimalPkgs.jq;}).buildImageWithNixDb {
    name = "docker-ci";
    tag = "latest";

    contents = with pkgs; [
      ./root
      (replaceDependency
        {
          drv = minimalPkgs.bash;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (replaceDependency
        {
          drv = minimalPkgs.gnugrep;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (replaceDependency
        {
          drv = minimalPkgs.git;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (replaceDependency
        {
          drv = minimalPkgs.jq;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (replaceDependency
        {
          drv = minimalPkgs.nix;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (replaceDependency
        {
          drv = minimalPkgs.nix-eval-jobs;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (replaceDependency
        {
          drv = minimalPkgs.coreutils;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (writeTextFile {
        name = "nix.conf";
        destination = "/etc/nix/nix.conf";
        text = ''
          accept-flake-config = true
          experimental-features = nix-command flakes
          filter-syscalls = false
        '';
      })

      # runtime dependencies of nix
      (replaceDependency
        {
          drv = pkgs.cacert;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      # for our ci
      # cachix
      (replaceDependency
        {
          drv = ci-matrix;
          oldDependency = pkgs.glibc;
          newDependency = minimalPkgs.glibc;
        })

      (replaceDependency
        {
          drv =
            writeShellScriptBin "test-ci"
            ''
              cd /mnt
              export CACHIX_CACHE=mcl-blockchain-packages
              git config --global --add safe.directory /mnt
              ci-matrix.sh
            '';
          oldDependency = pkgs.bash;
          newDependency = minimalPkgs.bash;
        })
    ];

    extraCommands = ''
      # for /usr/bin/env
      mkdir usr
      ln -s ../bin usr/bin

      # make sure /tmp exists
      mkdir -m 1777 tmp

      # need a HOME
      mkdir -vp root
    '';

    config = {
      Cmd = ["/bin/bash"];
      Env = [
        "ENV=/etc/profile.d/nix.sh"
        "BASH_ENV=/etc/profile.d/nix.sh"
        "NIX_BUILD_SHELL=/bin/bash"
        "NIX_PATH=nixpkgs=${./fake_nixpkgs}"
        "PAGER=cat"
        "PATH=/usr/bin:/bin"
        "SSL_CERT_FILE=${(replaceDependency
          {
            drv = pkgs.cacert;
            oldDependency = pkgs.glibc;
            newDependency = minimalPkgs.glibc;
          })}/etc/ssl/certs/ca-bundle.crt"
        "USER=root"
      ];
    };
  };
in
  image
