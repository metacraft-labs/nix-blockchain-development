{pkgs}: rec {
  aws-sdk-cpp-nix-do-not-use =
    (pkgs.aws-sdk-cpp.override {
      apis = ["s3" "transfer"];
      customMemoryManagement = false;
    })
    .overrideAttrs {
      # only a stripped down version is build which takes a lot less resources to build
      requiredSystemFeatures = [];
    };

  glibc = pkgs.glibc.overrideAttrs (old: {
    postFixup = ''
      rm -rf $out/{share,libexec,lib/gconv/*}
    '';
  });

  gcc = pkgs.wrapCCWith {
    cc = pkgs.gcc-unwrapped;
    libc = glibc;
    bintools = pkgs.binutils.override {
      libc = glibc;
    };
  };

  stdenv = pkgs.overrideCC pkgs.stdenv gcc;

  acl = (pkgs.acl.override {inherit stdenv;}).overrideAttrs (old: {
    pname = old.pname + "-min";

    postFixup = ''
      rm -rf $out/share
    '';
  });

  libarchive = (pkgs.libarchive.override {inherit stdenv acl;}).overrideAttrs (old: {
    pname = old.pname + "-min";
  });
  gnugrep = (pkgs.gnugrep.override {inherit stdenv;}).overrideAttrs (old: {
    pname = old.pname + "-min";

    postFixup = ''
      rm -rf $out/share

      sed -i 's|${pkgs.bash}|${bash}|' $out/bin/*
    '';
    doCheck = false;
  });

  jq = (pkgs.jq.override {inherit stdenv;}).overrideAttrs (old: {
    pname = old.pname + "-min";

    # outputs = ["bin" "doc" "man" "dev" "lib" "out"];
    outputs = ["bin" "dev" "lib" "out"];
    configureFlags = old.configureFlags ++ ["--mandir=/tmp" "--datadir=/tmp"];
    postInstall = ''
      rm -rf $out/{share/{man,doc}},include,lib/pkgconfig}
    '';
  });

  coreutils =
    (pkgs.coreutils.override {
      inherit stdenv acl;

      gmpSupport = false;
      aclSupport = false;
      attrSupport = false;
    })
    .overrideAttrs
    (old: {
      pname = old.pname + "-min";
      postFixup = ''
        rm -rf $out/{share/info,lib/debug}} $info/* $debug/*
      '';
      passthru = {inherit stdenv acl;};
      doCheck = false;
    });

  libkrb5 = (pkgs.libkrb5.override {inherit stdenv;}).overrideAttrs (old: {
    pname = old.pname + "-min";
    postFixup = ''
      rm -rf $out/share
      sed -i 's|${pkgs.bash}|${bash}|' $out/bin/*
    '';
  });

  curl = (pkgs.curl.override {inherit stdenv libkrb5;}).overrideAttrs (old: {
    pname = old.pname + "-min";
    postFixup = ''
      rm -rf $out/share
    '';
  });
  nix =
    (pkgs.nixVersions.unstable.override {
      inherit
        stdenv
        coreutils
        libarchive
        curl
        ;

      enableDocumentation = false;
      withAWS = false;
      withLibseccomp = false;
    })
    .overrideAttrs (old: {
      pname = old.pname + "-min";
      postFixup = ''
        rm -rf $out/{/etc/profile.d/*.fish,libexec/nix/build-remote,share}
        ${pkgs.removeReferencesTo}/bin/remove-references-to -t ${aws-sdk-cpp-nix-do-not-use} $out/bin/nix $out/lib/libnixstore.so
      '';
      buildInputs = old.buildInputs ++ [pkgs.removeReferencesTo];
      #replacing references breaks the check phase
      doInstallCheck = false;
      passthru = {
        inherit
          stdenv
          coreutils
          libarchive
          curl
          ;
      };
    });

  nix-eval-jobs = (pkgs.nix-eval-jobs.override {inherit stdenv nix;}).overrideAttrs (old: {
    pname = old.pname + "-min";

    passthru = {inherit stdenv nix;};
  });

  # use bashInteractive instead of bash when testing
  bash =
    (pkgs.bash.override {
      inherit stdenv;
      withDocs = false;
    })
    .overrideAttrs (old: {
      # name = old.name + "-min";

      postFixup =
        old.postFixup
        + ''
          rm $out/bin/sh
          ln -s $out/bin/bash $out/bin/sh

          rm -rf $out/{include,lib/bash/{loadables.h,Makefile.sample}}
          sed -i 's|${pkgs.glibc}|${glibc}|' $out/{bin,lib/bash}/*
        '';
      passthru = {inherit stdenv;};
    });
  git =
    (
      pkgs.git.override {
        inherit bash;
        inherit stdenv;
        perlSupport = false;
        pythonSupport = false;
        withManual = false;
        withpcre2 = false;
        svnSupport = false;
        guiSupport = false;
      }
    )
    .overrideAttrs (
      old: {
        pname = old.pname + "-min";

        # installCheck is broken when perl is disabled
        doInstallCheck = false;
        postFixup = ''
          mkdir -p $out/share2
          cp -r $out/share/git-core $out/share2/
          rm -rf $out/share
          mv $out/share2 $out/share
          rm -rf $out/libexec/git-core/{mergetools,.git-*,git-{archimport,citool,cvs*,daemon,difftool--helper,\
          filter-branch,gui--askpass,http-*,imap-send,instaweb,merge*,p4,quiltimport,request-pull,send-email,shell,subtree,web--browse},scalar} \
          $out/bin/{scalar,git-{credential-netrc,cvsserver,shell}}

          sed -i 's|${pkgs.bash}|${bash}|' $out/bin/git $out/libexec/git-core/git
        '';
      }
    );
}
