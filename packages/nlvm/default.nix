{
  pkgs,
  fetchgit,
  fetchurl,
  symlinkJoin,
  hostPlatform,
}:
pkgs.stdenvNoCC.mkDerivation rec {
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
      bintools
    ];
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
    ./make-llvm.sh.diff
    ./dl-llvm.sh.diff
  ];

  meta = with pkgs.lib; {
    homepage = "https://github.com/arnetheduck/nlvm";
    platforms = platforms.linux;
  };

  STATIC_LLVM = 1;

  CC = "clang";
  CXX = "clang++";
  C_INCLUDE_PATH = "${llvmEnv}/include:${pkgs.gcc-unwrapped}/lib/gcc/${hostPlatform.config}/${pkgs.gcc-unwrapped.version}/include:${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}:${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}/${hostPlatform.config}:${pkgs.gcc-unwrapped}/lib/gcc/${hostPlatform.config}/${pkgs.gcc-unwrapped.version}/include-fixed:${pkgs.glibc.dev}/include";
  CPLUS_INCLUDE_PATH = "${C_INCLUDE_PATH}";

  CFLAGS = "-I${llvmEnv}/include  -I${pkgs.gcc-unwrapped}/lib/gcc/${hostPlatform.config}/${pkgs.gcc-unwrapped.version}/include -I${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version} -I${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc-unwrapped.version}/${hostPlatform.config} -I${pkgs.gcc-unwrapped}/lib/gcc/${hostPlatform.config}/${pkgs.gcc-unwrapped.version}/include-fixed -I${pkgs.glibc.dev}/include";
  CPPFLAGS = "${CFLAGS}";
  LDFLAGS = "-lm -lc -lunwind -lstdc++";
  LDLIBS = "-L${llvmEnv}/lib -L${pkgs.zstd.out}/lib -L${pkgs.glibc}/lib -L${pkgs.gcc-unwrapped}/lib";
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
    sed "s#LLVMRoot = fmt\"../ext/llvm-{LLVMVersion}.src/\"#LLVMRoot = \"${llvmEnv}/\"#" -i llvm/llvm.nim
    sed "s#LLDRoot = fmt\"../ext/lld-{LLVMVersion}.src/\"#LLDRoot = \"${llvmEnv}/\"#" -i llvm/llvm.nim
    sed "s#LLVMOut = LLVMRoot & \"sha/\"#LLVMOut = LLVMRoot#" -i llvm/llvm.nim
    sed "s#LLVMOut = LLVMRoot & \"sta/\"#LLVMOut = LLVMRoot#" -i llvm/llvm.nim
    sed "s#sta/bin/llvm-config#bin/llvm-config#" -i llvm/llvm.nim
    sed "s#LLVMRoot & \"sta/bin/llvm-config#LLVMRoot & \"bin/llvm-config#" -i llvm/llvm.nim
    sed "s#\$ORIGIN/##" -i llvm/llvm.nim
    sed "s#-Wl,'##" -i llvm/llvm.nim
    sed "s#lib/'#lib/#" -i llvm/llvm.nim
    sed "s#-Wl,--as-needed#--as-needed#" -i llvm/llvm.nim

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

    WTF

  '';

  makefile = "Makefile nlvm/nlvmr";

  installPhase = ''
    mkdir -p $out/bin
    cp nlvm/nlvmr $out/bin/nlvm
    cp -r nlvm-lib $out/bin
  '';

  nativeBuildInputs = with pkgs; [
    zlib
    openssl
    wget
    pcre
    sqlite
    nim
    python3
    clang
    llvmPackages_16.bintools
  ];
  buildInputs = with pkgs; [
    ninja
    cmake
  ];
}
