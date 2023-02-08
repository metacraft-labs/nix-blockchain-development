{
  lib,
  fetchgit,
  pkgs,
  clang13Stdenv,
}:
clang13Stdenv.mkDerivation rec {
  pname = "zkllvm";
  version = "0.0.34";

  src =
    (fetchgit {
      url = "https://github.com/nilfoundation/zkllvm.git";
      rev = "v${version}";
      sha256 = "sha256-cNR7xjsf57n/ItIFKr0U1EOEPwrjuz29kynhk5Ubj9U=";
      fetchSubmodules = true;
      deepClone = true;
    })
    .overrideAttrs (_: {
      GIT_CONFIG_COUNT = 1;
      GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
      GIT_CONFIG_VALUE_0 = "git@github.com:";
    });

  buildPhase = ''
    cmake -G "Unix Makefiles" -B build -DCMAKE_BUILD_TYPE=Release -DCIRCUIT_ASSEMBLY_OUTPUT=TRUE .
    make assigner clang -j$(nproc)
  '';

  nativeBuildInputs = with pkgs; [pkgconfig cmake python3 git];

  buildInputs = with pkgs; [boost openssl llvmPackages_13.llvm];
}
