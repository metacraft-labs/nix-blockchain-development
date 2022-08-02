{
  pkgs,
  fetchgit,
  fetchurl,
}:
pkgs.clangStdenv.mkDerivation rec {
  name = "nlvm-${version}";
  version = "0";

  src = fetchgit {
    url = "https://github.com/arnetheduck/nlvm";
    fetchSubmodules = true;
    deepClone = true;
    sha256 = "sha256-bzKGLwFHQGOkyyPNmlTK9AgWRqDgho5UpkaNwiMaoIA=";
    rev = "92f43a3450e0b6f4999dc21e59b1bb6a1341ec85";
  };

  LLVM_MAJ = "14";
  LLVM_MIN = "0";
  LLVM_PAT = "0";
  LLVM_VER = "${LLVM_MAJ}.${LLVM_MIN}.${LLVM_PAT}";
  SUFFIX = "x86_64-linux-gnu-ubuntu-18.04";

  clang_llvm = fetchurl {
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/clang+llvm-${LLVM_VER}-${SUFFIX}.tar.xz";
    sha256 = "sha256-YVgiFdr6+3tXbqMMwTa+ksh3uh8cMd2703LW1lYi/vU=";
  };
  llvm = fetchurl {
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/llvm-${LLVM_VER}.src.tar.xz";
    sha256 = "sha256-TfftULi3AXuQ3CIgL2tZ6QBqKalWgjjGryjfnASce5s=";
  };
  lld = fetchurl {
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/lld-${LLVM_VER}.src.tar.xz";
    sha256 = "sha256-iPwPAoqowNkoeSCxAfKIsDx/q7WEB3MmxaC+SC65EVw=";
  };
  libunwind = fetchurl {
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/libunwind-${LLVM_VER}.src.tar.xz";
    sha256 = "sha256-QJsxB5quh73GO5b/v9IrsUJRO+0Or9MncTkf8XSAJc4=";
  };

  csources_v1 = fetchgit {
    url = "https://github.com/nim-lang/csources_v1";
    fetchSubmodules = true;
    deepClone = true;
    sha256 = "sha256-gwBFuR7lzO4zttR/6rgdjXMRxVhwKeLqDwpmOwMyU7A=";
    rev = "561b417c65791cd8356b5f73620914ceff845d10";
  };

  patches = [
    ./Makefile.diff
  ];

  meta = with pkgs.lib; {
    homepage = "https://github.com/arnetheduck/nlvm";
    platforms = platforms.linux;
  };

  CC = "clang";
  CXX = "clang++";
  C_INCLUDE_PATH = "${pkgs.gcc11}/lib/gcc/x86_64-unknown-linux-gnu/11.3.0/include-fixed:${pkgs.glibc.dev}/include";
  CPLUS_INCLUDE_PATH = "${C_INCLUDE_PATH}";

  CFLAGS = "-stdlib=libstdc++";
  # LDFLAGS = "-lm -lc++ -lc -lunwind -L${pkgs.llvmPackages_14.lld.lib}/lib -L${pkgs.zlib}/lib -L${pkgs.llvmPackages_14.libcxx}/lib -L${pkgs.llvmPackages_14.libcxxabi}/lib -L${pkgs.glibc}/lib  -L${pkgs.llvmPackages_14.libunwind}/lib";
  LDFLAGS = "-lm -lstdc++ -lc -lunwind -L../ext/llvm-14.0.0.src/sha/lib -L${pkgs.llvmPackages_14.lld.lib}/lib -Lext/libunwind-14.0.0.src/sha/lib -L${pkgs.zlib}/lib -L${pkgs.glibc}/lib -L${pkgs.llvmPackages_14.libunwind}/lib  -L${pkgs.gcc11}/lib";
  LIBCLANG_PATH = "${pkgs.llvmPackages_14.libclang.lib}/lib";

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  preConfigurePhases = ["postUnpackPhase"];
  postUnpackPhase = ''
    export HOME=$TMPDIR
    mkdir -p ext

    # sed "s#LLVMPATH=../ext#LLVMPATH='${pkgs.llvmPackages_14.llvm}'#" -i Makefile
    # sed "s#LLVMRoot = \"../ext/llvm-14.0.0.src/\"#LLVMRoot = \"${pkgs.llvmPackages_14.llvm.dev}/\"#" -i llvm/llvm.nim
    # sed "s#LLDRoot = \"../ext/lld-14.0.0.src/\"#LLDRoot = \"${pkgs.llvmPackages_14.lld.dev}/\"#" -i llvm/llvm.nim
    # sed "s#LLVMOut = LLVMRoot & \"sha/\"#LLVMOut = LLVMRoot#" -i llvm/llvm.nim
    # sed "s#LLVMOut = LLVMRoot & \"sta/\"#LLVMOut = LLVMRoot#" -i llvm/llvm.nim
    # sed "s#sta/bin/llvm-config#/bin/llvm-config#" -i llvm/llvm.nim
    # sed "s#\$ORIGIN/##" -i llvm/llvm.nim
    # sed "s#-Wl,'##" -i llvm/llvm.nim
    # sed "s#lib/'#lib/#" -i llvm/llvm.nim
    # sed "s#-Wl,--as-needed#--as-needed#" -i llvm/llvm.nim



    sed 's#LLVMRoot & \"sta/bin/llvm-config#\"${pkgs.llvmPackages_14.llvm.dev}/bin/llvm-config#' -i llvm/llvm.nim
    sed 's#LLVMOut & \"bin/llvm-config#\"${pkgs.llvmPackages_14.llvm.dev}/bin/llvm-config#' -i llvm/llvm.nim
    sed "s#-Wl,'##" -i llvm/llvm.nim
    sed "s#-Wl,--as-needed#--as-needed#" -i llvm/llvm.nim


    cp ${clang_llvm} ext/clang+llvm-${LLVM_VER}-${SUFFIX}.tar.xz
    cp ${llvm} ext/llvm-${LLVM_VER}.src.tar.xz
    cp ${lld} ext/lld-${LLVM_VER}.src.tar.xz
    cp ${libunwind} ext/libunwind-${LLVM_VER}.src.tar.xz

    # mkdir -p Nim
    cp -r ${csources_v1} Nim/csources_v1

    cat >> config.nims << WTF
    switch("cc", "clang")
    WTF

    cat >> nim.cfg << WTF
    clang.cpp.exe %= "clang++"
    clang.cpp.linkerexe %= "ld.lld"
    clang.exe %= "clang"
    clang.linkerexe %= "ld.lld"

    clang.options = "${CFLAGS}"
    clang.cpp.options = "${CFLAGS}"

    clang.options.linker = "${LDFLAGS}"
    clang.cpp.options.linker = "${LDFLAGS}"

    gcc.cpp.exe %= "\$CXX"
    gcc.cpp.linkerexe %= "\$CXX"
    gcc.exe %= "\$CC"
    gcc.linkerexe %= "\$CC"
    WTF

  '';

  nativeBuildInputs = with pkgs; [
    zlib
    llvmPackages_14.clang-unwrapped
    llvmPackages_14.llvm
    llvmPackages_14.lld
    llvmPackages_14.libcxx
    llvmPackages_14.libcxxabi
    llvmPackages_14.libunwind
    gcc11
    openssl
    wget
    pcre
    sqlite
    nim
    python3
    glibc
    # ninja
    # cmake
  ];
  buildInputs = with pkgs; [
    ninja
    cmake
  ];

  STATIC_LLVM = 1;
}
