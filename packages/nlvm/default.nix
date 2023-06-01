{
  pkgs,
  fetchgit,
  fetchurl,
  symlinkJoin,
}:
pkgs.clangStdenv.mkDerivation rec {
  name = "nlvm-${version}";
  version = "dev-2023-06-01";

  src = fetchgit {
    url = "https://github.com/arnetheduck/nlvm";
    fetchSubmodules = true;
    deepClone = true;
    rev = "59db5053304d46aaf72a1c9e00b86353812eacbb";
    hash = "sha256-rgq0Of7JrFDXIu5Hsz6bNkO3UY5uAeFz9AYEOfMkJ7Y=";
  };

  llvmEnv = symlinkJoin {
    name = "nlvm-llvm-${version}";
    paths = with pkgs.llvmPackages_16; [
      clang-unwrapped
      clang-unwrapped.lib
      clang-unwrapped.dev
      lld
      lld.lib
      lld.dev
      llvm
      llvm.lib
      llvm.dev
      libunwind
      libunwind.dev
      libclang
      libclang.lib
      libclang.dev
      libcxx
      libcxx.dev
      libcxxabi
      libcxxabi.dev
      bintools
    ];
  };

  # clang_llvm = fetchurl {
  #   url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/clang+llvm-${LLVM_VER}-${SUFFIX}.tar.xz";
  #   sha256 = "sha256-YVgiFdr6+3tXbqMMwTa+ksh3uh8cMd2703LW1lYi/vU=";
  # };
  # llvm = fetchurl {
  #   url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/llvm-${LLVM_VER}.src.tar.xz";
  #   sha256 = "sha256-TfftULi3AXuQ3CIgL2tZ6QBqKalWgjjGryjfnASce5s=";
  # };
  # lld = fetchurl {
  #   url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/lld-${LLVM_VER}.src.tar.xz";
  #   sha256 = "sha256-iPwPAoqowNkoeSCxAfKIsDx/q7WEB3MmxaC+SC65EVw=";
  # };
  # libunwind = fetchurl {
  #   url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/libunwind-${LLVM_VER}.src.tar.xz";
  #   sha256 = "sha256-QJsxB5quh73GO5b/v9IrsUJRO+0Or9MncTkf8XSAJc4=";
  # };

  csources_v1 = fetchgit {
    url = "https://github.com/nim-lang/csources_v1";
    fetchSubmodules = true;
    deepClone = true;
    sha256 = "sha256-gwBFuR7lzO4zttR/6rgdjXMRxVhwKeLqDwpmOwMyU7A=";
    rev = "561b417c65791cd8356b5f73620914ceff845d10";
  };

  patches = [
    ./Makefile.diff
    ./make-llvm.sh.diff
  ];

  meta = with pkgs.lib; {
    homepage = "https://github.com/arnetheduck/nlvm";
    platforms = platforms.linux;
  };

  CC = "clang";
  CXX = "clang++";
  C_INCLUDE_PATH = "${llvmEnv}/include:${llvmEnv}/include/c++/v1";
  CPLUS_INCLUDE_PATH = "${C_INCLUDE_PATH}";

  CFLAGS = "-I${llvmEnv}/include -I${llvmEnv}/include/c++/v1";
  CPPFLAGS = "${CFLAGS}";
  LDFLAGS = "-lm -lc -lunwind";
  LDLIBS = "-L${llvmEnv}/lib -L${pkgs.zstd.out}/lib";
  LIBCLANG_PATH = "${llvmEnv}/lib";

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  preConfigurePhases = ["postUnpackPhase"];
  postUnpackPhase = ''
    export HOME=$TMPDIR
    mkdir -p ext

    sed "s#LLVMPATH=../ext#LLVMPATH='${llvmEnv}'#" -i Makefile
    sed "s#LLVMRoot = \"../ext/llvm-16.0.1.src/\"#LLVMRoot = \"${llvmEnv}/\"#" -i llvm/llvm.nim
    sed "s#LLDRoot = \"../ext/lld-16.0.1.src/\"#LLDRoot = \"${llvmEnv}/\"#" -i llvm/llvm.nim
    sed "s#LLVMOut = LLVMRoot & \"sha/\"#LLVMOut = LLVMRoot#" -i llvm/llvm.nim
    sed "s#LLVMOut = LLVMRoot & \"sta/\"#LLVMOut = LLVMRoot#" -i llvm/llvm.nim
    sed "s#sta/bin/llvm-config#/bin/llvm-config#" -i llvm/llvm.nim
    sed "s#\$ORIGIN/##" -i llvm/llvm.nim
    sed "s#-Wl,'##" -i llvm/llvm.nim
    sed "s#lib/'#lib/#" -i llvm/llvm.nim
    sed "s#-Wl,--as-needed#--as-needed#" -i llvm/llvm.nim



    sed 's#LLVMRoot & \"sta/bin/llvm-config#\"${llvmEnv}/bin/llvm-config#' -i llvm/llvm.nim
    sed 's#LLVMOut & \"bin/llvm-config#\"${llvmEnv}/bin/llvm-config#' -i llvm/llvm.nim
    sed "s#-Wl,'##" -i llvm/llvm.nim
    sed "s#-Wl,--as-needed#--as-needed#" -i llvm/llvm.nim


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

    clang.options.linker = "${LDLIBS} ${LDFLAGS}"
    clang.cpp.options.linker = "${LDLIBS} ${LDFLAGS}"

    gcc.cpp.exe %= "\$CXX"
    gcc.cpp.linkerexe %= "\$CXX"
    gcc.exe %= "\$CC"
    gcc.linkerexe %= "\$CC"
    WTF

  '';

  nativeBuildInputs = with pkgs; [
    zlib
    openssl
    wget
    pcre
    sqlite
    nim
    python3
    llvmPackages_16.bintools
  ];
  buildInputs = with pkgs; [
    ninja
    cmake
  ];

  # STATIC_LLVM = 1;
}
