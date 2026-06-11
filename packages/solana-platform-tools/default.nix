{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  ncurses,
  openssl,
  python310,
  libxml2,
  libedit,
  xz,
  ...
}:
let
  version = "v1.52";

  # Anza-xyz's platform-tools tarball.  Same upstream payload the
  # cargo-build-sbf installer downloads on first use into
  # ``~/.cache/solana/<version>/platform-tools``, but NixOS can't run
  # those generic-Linux dynamically-linked binaries directly
  # (``Could not start dynamically linked executable .../rust/bin/rustc
  # / NixOS cannot run dynamically linked executables intended for
  # generic linux environments``).  Vendor the tarball through nix +
  # autoPatchelfHook so the binaries get a NixOS-compatible interpreter
  # and rpath baked in at install time.
  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://github.com/anza-xyz/platform-tools/releases/download/${version}/platform-tools-linux-x86_64.tar.bz2";
        hash = "sha256-izhh6T2vCF7BK2XE+sN02b7EWHo94Whx2msIqwwdkH4=";
      }
    else if stdenv.hostPlatform.system == "aarch64-linux" then
      fetchurl {
        url = "https://github.com/anza-xyz/platform-tools/releases/download/${version}/platform-tools-linux-aarch64.tar.bz2";
        hash = "sha256-sfhbLsR+9tUPZoPjUUv0apUmlQMVUXjN+0i9aUszH5g=";
      }
    else if stdenv.hostPlatform.system == "aarch64-darwin" then
      fetchurl {
        url = "https://github.com/anza-xyz/platform-tools/releases/download/${version}/platform-tools-osx-aarch64.tar.bz2";
        hash = "sha256-Fyffsx6DPOd30B5wy0s869JrN2vwnYBSfwJFfUz2/QA=";
      }
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      fetchurl {
        url = "https://github.com/anza-xyz/platform-tools/releases/download/${version}/platform-tools-osx-x86_64.tar.bz2";
        hash = "sha256-HdTysfe1MWwvGJjzfHXtSV7aoIMzM0kVP+lV5Wg3kdE=";
      }
    else
      throw "unsupported system for solana-platform-tools: ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "solana-platform-tools";
  inherit version src;

  nativeBuildInputs = [ autoPatchelfHook ];

  # The downloaded binaries link against a generic-Linux runtime;
  # autoPatchelfHook rewrites their ELF interpreter + RPATH so they
  # resolve through nix's glibc/libstdc++/zlib/openssl/ncurses/libxml2
  # instead.  ``python310`` is specifically needed because llvm/lib's
  # ``liblldb`` was built against Python 3.10 (later python versions
  # have ABI-incompatible libpython.so.1 names); ``libedit``,
  # ``libxml2`` and ``xz`` cover the rest of lldb's runtime deps.
  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    ncurses
    openssl
    python310
    libxml2
    libedit
    xz
  ];

  # liblldb-20.1.7 links against ``libedit.so.2`` which nixpkgs has at
  # ``.so.0`` only -- an ABI bump in libedit's upstream that hasn't
  # propagated yet.  And the bundled liblldb wants
  # ``libxml2.so.2.10`` whereas nixpkgs ships ``libxml2.so.2.13`` (the
  # SONAME embedded in the binary doesn't match the system's exact
  # minor).  These mismatches only matter when something invokes
  # ``lldb``, which cargo-build-sbf does not.  Ignore the missing
  # deps so the rustc / cargo / clang binaries (which DO get fully
  # patched) install cleanly; lldb is intentionally non-functional
  # in this nix derivation.
  autoPatchelfIgnoreMissingDeps = [
    "libedit.so.2"
    "libxml2.so.2"
  ];

  # The tarball extracts as ``./llvm/``, ``./rust/``, ``./version.md``
  # at top level (no enclosing directory).  Mirror that into ``$out``
  # so a single symlink from
  # ``$HOME/.cache/solana/v<version>/platform-tools -> $out``
  # presents the canonical layout cargo-build-sbf expects.
  unpackPhase = ''
    runHook preUnpack
    mkdir -p source
    tar -xjf "$src" -C source
    runHook postUnpack
  '';

  sourceRoot = "source";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r llvm "$out/llvm"
    cp -r rust "$out/rust"
    if [ -f version.md ]; then
      cp version.md "$out/version.md"
    fi

    # The llvm/lib/python3.10/dist-packages/lldb/ directory contains
    # symlinks back to ``../../../../bin/lldb-argdumper`` and
    # ``../../../../lib/liblldb.so`` -- both paths the platform-tools
    # tarball expects to find at the *layout root* (i.e.,
    # ``$out/bin/`` and ``$out/lib/``), but we install ``llvm`` and
    # ``rust`` as siblings instead, so the parent directories don't
    # exist and noBrokenSymlinks aborts the build.
    #
    # cargo-build-sbf doesn't invoke lldb at any point of the SBF
    # build path -- it only ever spawns rustc / cargo / llvm-ar /
    # clang from ``rust/bin`` and ``llvm/bin``.  Drop the broken
    # python bindings entirely.
    rm -rf "$out/llvm/lib/python3.10/dist-packages/lldb"
    runHook postInstall
  '';

  # The downloaded rust/cargo/llvm tools include libraries that
  # autoPatchelfHook can't always resolve (e.g. libLLVM-* references
  # private libraries shipped alongside them in the same dir).  Add
  # those install-tree directories to the patched RPATH explicitly.
  appendRunpaths = [
    "$out/rust/lib"
    "$out/llvm/lib"
  ];

  meta = {
    description = "Anza-xyz platform-tools (rustc + llvm) for Solana SBF builds, NixOS-patched";
    homepage = "https://github.com/anza-xyz/platform-tools";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
