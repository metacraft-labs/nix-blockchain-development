{
  lib,
  fetchgit,
  pkgs,
  clang13Stdenv,
}: let
  boost-custom = pkgs.boost.override {
    enableShared = false;
    enableStatic = true;
    enableIcu = true;
  };
in
  clang13Stdenv.mkDerivation rec {
    pname = "zkllvm";
    version = "0.1.3";
    src =
      (fetchgit {
        url = "https://github.com/nilfoundation/zkllvm.git";
        rev = "v${version}";
        sha256 = "sha256-rPbG2xRQAIJv4YSTXMxLWUhG3EKT62X3zOMeVsgic6Q=";
        fetchSubmodules = true;
        deepClone = true;
        leaveDotGit = true;
      })
      .overrideAttrs (_: {
        GIT_CONFIG_COUNT = 1;
        GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
        GIT_CONFIG_VALUE_0 = "git@github.com:";
      });

    postPatch = ''
      sed -i 's#set(ZKLLVM_DEV_ENVIRONMENT TRUE)#set(ZKLLVM_DEV_ENVIRONMENT TRUE)\nset(ZKLLVM_VERSION \"${version}\")#' CMakeLists.txt
    '';

    buildPhase = ''
      mkdir build
      cmake -G "Unix Makefiles" -B build -DCMAKE_BUILD_TYPE=Release -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE .

      make -j$(nproc)
      make assigner clang -j$(nproc)
      # make rslang -j$(nproc)
      ls bbuild
    '';

    nativeBuildInputs = with pkgs; [pkgconfig cmake python3 git];

    buildInputs = with pkgs; [boost-custom spdlog icu openssl llvmPackages_13.llvm git];
  }
