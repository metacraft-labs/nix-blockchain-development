{
  rustFromToolchainFile,
  craneLib,
  fetchFromGitHub,
  pkg-config,
  openssl,
  perl,
  makeWrapper,
  writeShellScript,
  stdenv,
  solana-platform-tools,
  ...
}:
let
  commonArgs = rec {
    pname = "cargo-build-sbf";
    version = "3.1.11";

    nativeBuildInputs = [
      pkg-config
      openssl
      perl # needed by openssl-sys build script
      makeWrapper
    ];

    src = fetchFromGitHub {
      owner = "anza-xyz";
      repo = "agave";
      rev = "v${version}";
      hash = "sha256-gTN+SzfOz3uPq/nDGsiBz3Y4GnV0hm+1qV7Q1Gwcb2g=";
    };

    # These workspace members lack src/ directories, which breaks crane's
    # dummy-source replacement. Create minimal stubs instead of removing them
    # from Cargo.toml (which would invalidate the vendored Cargo.lock).
    postPatch = ''
      for d in client-test keygen programs/bpf-loader-tests \
                programs/compute-budget-bench programs/ed25519-tests \
                programs/zk-elgamal-proof-tests rpc-test dev-bins programs/sbf; do
        mkdir -p "$d/src"
        touch "$d/src/lib.rs"
      done
    '';
    cargoCheckCommand = "cargo check --release -p solana-cargo-build-sbf";
    cargoBuildCommand = "cargo build --release -p solana-cargo-build-sbf";
    cargoTestCommand = "true";
  };

  rust-toolchain = rustFromToolchainFile {
    dir = commonArgs.src;
    sha256 = "sha256-X/4ZBHO3iW0fOenQ3foEvscgAPJYl2abspaBThDOukI=";
  };

  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // rec {
    inherit cargoArtifacts;

    doCheck = false;

    # cargo-build-sbf has two read-only-filesystem / missing-tool
    # hazards when run from a nix store path inside a nix dev shell.
    # Both pivot on the binary assuming the upstream Solana toolchain
    # provisioning workflow (rustup-managed ``+solana`` override
    # registered out of band, ``~/.cache/solana`` writable).  We
    # provision everything from nix instead -- so the wrapper
    # rearranges things to suit that model.
    #
    # 1. The default ``--sbf-sdk`` is ``<bindir>/platform-tools-sdk/sbf``
    #    and the binary exits with ``Solana SDK path does not exist`` if
    #    that directory is missing.  Vendor the helper scripts (env.sh,
    #    scripts/, c/) straight from the agave checkout so the
    #    structural pre-flight passes.
    #
    # 2. ``toolchain::install_if_missing`` (see agave platform-tools-sdk/
    #    cargo-build-sbf/src/toolchain.rs) writes a symlink at
    #    ``<sbf_sdk>/dependencies/platform-tools`` → the writable cache
    #    at ``$HOME/.cache/solana/v<tools-version>/platform-tools/``.
    #    With sbf_sdk in the nix store that ``create_dir_all`` call
    #    fails with ``Read-only file system (os error 30)`` and the
    #    binary aborts with ``Failed to install platform-tools``.
    #
    # The default control flow then calls ``link_solana_toolchain``
    # which spawns ``rustup toolchain list -v`` to register the
    # downloaded platform-tools rust as a ``+solana`` cargo override.
    # We don't use rustup -- nix manages the rust toolchain end of
    # things -- so pass ``--no-rustup-override`` to skip that branch
    # entirely.  The alternate branch
    # (``check_solana_target_installed``) just runs ``rustc --print
    # target-list`` and confirms the SBF target is supported; we point
    # ``RUSTC`` at the downloaded platform-tools rust binary which
    # carries the SBF target built-in, so the check passes against
    # the same toolchain cargo will use for the actual build.
    #
    # Putting it together:
    #   * Move the vendored ``sbf`` helpers to
    #     ``$out/share/cargo-build-sbf/sbf`` (immutable reference).
    #   * Wrap the binary so it materialises a writable mirror at
    #     ``$HOME/.cache/solana/cargo-build-sbf-sdk`` on first
    #     invocation (symlinks for the read-only helpers, real
    #     directory for ``dependencies/``).
    #   * Point ``SBF_SDK_PATH`` at that writable mirror.
    #   * Prepend ``--no-rustup-override`` so the rustup-spawn branch
    #     is never taken.
    #   * Point ``RUSTC`` at the cached platform-tools rust
    #     (downloaded by ``install_if_missing`` on the first run);
    #     until the cache is warm, fall back to the system rustc so
    #     the very first invocation -- which only needs to *download*
    #     platform-tools, not run target-list against it -- still
    #     proceeds.
    postInstall = ''
      mkdir -p "$out/share/cargo-build-sbf"
      cp -r platform-tools-sdk/sbf "$out/share/cargo-build-sbf/sbf"

      mv "$out/bin/cargo-build-sbf" "$out/bin/.cargo-build-sbf-unwrapped"
      cat > "$out/bin/cargo-build-sbf" <<EOF
      #!${stdenv.shell}
      set -euo pipefail

      # cargo-build-sbf wants to write into <sbf_sdk>/dependencies/
      # (see toolchain::install_if_missing).  With sbf_sdk in the nix
      # store that fails with Read-only filesystem.  Materialise a
      # writable mirror in \$HOME/.cache/solana/cargo-build-sbf-sdk that
      # symlinks the read-only helpers from the nix store and reserves
      # a real (writable) ``dependencies/`` subdirectory for the
      # symlink-to-cache the binary creates on first use.
      cache_root="\''${HOME:-/tmp}/.cache/solana"
      sdk_dir="\$cache_root/cargo-build-sbf-sdk"
      mkdir -p "\$sdk_dir"
      for helper in c env.sh scripts; do
        target="\$sdk_dir/\$helper"
        if [ ! -e "\$target" ]; then
          ln -s "$out/share/cargo-build-sbf/sbf/\$helper" "\$target"
        fi
      done
      mkdir -p "\$sdk_dir/dependencies"

      # Only override SBF_SDK_PATH when the caller hasn't set one
      # explicitly.  Users who point at their own writable SDK
      # (e.g. a manually-managed agave checkout) keep that behaviour.
      if [ -z "\''${SBF_SDK_PATH:-}" ]; then
        export SBF_SDK_PATH="\$sdk_dir"
      fi

      # ``install_if_missing`` would otherwise download the generic-
      # Linux platform-tools tarball from GitHub and try to run
      # ``rust/bin/rustc`` from inside ``~/.cache/solana/v1.52/
      # platform-tools/``.  Those binaries can't be executed on NixOS
      # (missing /lib64/ld-linux-x86-64.so.2 interpreter -- the
      # ``Could not start dynamically linked executable / NixOS cannot
      # run dynamically linked executables intended for generic linux
      # environments`` error).
      #
      # We ship a nix-built, autoPatchelfHook'd derivation
      # (solana-platform-tools) that mirrors the same layout with a
      # NixOS-compatible ELF interpreter and rpath baked in.  Point
      # the cache at it as a symlink so:
      #   * ``install_if_missing``'s pre-check (target_path is a
      #     non-empty directory) is satisfied and the download is
      #     skipped entirely.
      #   * Every subsequent ``cargo / rustc / llvm-ar / clang``
      #     invocation the binary spawns from
      #     ``platform-tools/<rust|llvm>/bin/`` resolves to a patched
      #     ELF that actually runs on NixOS.
      platform_tools_root="\$cache_root/v1.52"
      mkdir -p "\$platform_tools_root"
      link="\$platform_tools_root/platform-tools"
      nix_pt="${solana-platform-tools}"
      if [ -L "\$link" ]; then
        # Already a symlink.  Re-point only if it doesn't already
        # match the current nix derivation (older nix-blockchain-
        # development pin would have used a different store path).
        if [ "\$(readlink "\$link")" != "\$nix_pt" ]; then
          rm "\$link"
          ln -s "\$nix_pt" "\$link"
        fi
      elif [ -e "\$link" ]; then
        # Path exists but isn't a symlink -- that means a previous
        # ``cargo-build-sbf`` invocation (most likely from before
        # this wrapper landed) ran ``install_if_missing``'s
        # download path and unpacked the upstream-Linux tarball as
        # a real directory at this location.  On NixOS the
        # binaries inside that real directory fail to execute with
        # ``Could not start dynamically linked executable / NixOS
        # cannot run dynamically linked executables intended for
        # generic linux environments``.  Replace it with the
        # symlink so subsequent invocations hit the autoPatchelf'd
        # nix-store toolchain.
        rm -rf "\$link"
        ln -s "\$nix_pt" "\$link"
      else
        ln -s "\$nix_pt" "\$link"
      fi

      # The downloaded platform-tools rust binary lives at this
      # well-known location -- after the symlink above, it points at
      # the patched nix-store rustc.  Point RUSTC at it so that
      # ``check_solana_target_installed`` (which we reach via
      # ``--no-rustup-override`` below) confirms the SBF target is
      # supported by the same rustc cargo will use for the actual
      # build.
      # Always override RUSTC to the patched platform-tools rust --
      # the dev shell that loads ``cargo-build-sbf`` typically also
      # provides a stock ``pkgs.rustc`` (1.91 from nixpkgs) and may
      # export ``RUSTC`` pointing at it (so other rust tooling
      # behaves consistently).  That stock rustc does **not** ship
      # the ``sbpf-solana-solana`` target, so ``cargo-build-sbf``'s
      # ``check_solana_target_installed`` aborts with::
      #
      #   ERROR cargo_build_sbf::toolchain] Provided "rustc" does
      #   not have sbpf-solana-solana target.
      #
      # observed against the recorder's CI dev shell.  Overriding
      # unconditionally guarantees the SBF build path uses the
      # patched rustc regardless of whatever the enclosing shell
      # set on entry; the rest of the recorder cargo workflow
      # doesn't reach this wrapper, so the override is scoped to
      # the ``cargo build-sbf`` invocation alone.
      tools_rustc="\$cache_root/v1.52/platform-tools/rust/bin/rustc"
      if [ -x "\$tools_rustc" ]; then
        export RUSTC="\$tools_rustc"
      fi

      # We manage the rust toolchain with nix -- there is no rustup
      # in the dev shell to spawn for the ``+solana`` cargo override.
      # ``--no-rustup-override`` routes through the alternate
      # ``check_solana_target_installed`` branch which honours RUSTC.
      # Inject it only when the caller hasn't already passed it.
      has_no_rustup=0
      for arg in "\$@"; do
        if [ "\$arg" = "--no-rustup-override" ]; then
          has_no_rustup=1
          break
        fi
      done
      if [ \$has_no_rustup -eq 0 ]; then
        # ``cargo build-sbf`` dispatches to ``cargo-build-sbf`` with
        # the literal ``build-sbf`` token as argv[1] (cargo's
        # external-subcommand convention).  agave's clap parser
        # rejects ``--no-rustup-override build-sbf …`` because
        # ``build-sbf`` lands in positional position and clap
        # doesn't recognise it -- so prepend the flag *after* the
        # subcommand token when present.
        if [ \$# -gt 0 ] && [ "\$1" = "build-sbf" ]; then
          subcmd="\$1"
          shift
          set -- "\$subcmd" --no-rustup-override "\$@"
        else
          set -- --no-rustup-override "\$@"
        fi
      fi

      exec "$out/bin/.cargo-build-sbf-unwrapped" "\$@"
      EOF
      chmod +x "$out/bin/cargo-build-sbf"
    '';
  }
)
