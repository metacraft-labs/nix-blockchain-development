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

      # env.sh sources scripts/install.sh on every cargo build-sbf
      # invocation; that script's final action (after the
      # tarball extraction we've already short-circuited via the
      # ``~/.cache/solana/v1.52/platform-tools`` symlink) is to call
      # ``rustup toolchain link 1.89.0-sbpf-solana-v1.52
      # platform-tools/rust`` so downstream ``cargo +1.89.0-sbpf-...
      # build`` invocations resolve the platform-tools rust toolchain.
      # We don't use rustup -- nix manages the toolchain and the
      # wrapper passes ``--no-rustup-override`` so cargo-build-sbf's
      # build path uses ``$RUSTC`` instead of ``+solana``.  Without
      # rustup on PATH the script fails with::
      #
      #   .../install.sh: line 151: rustup: command not found
      #
      # Strip the rustup block (lines 134..151 in the upstream
      # script, identified by the ``mapfile -t toolchains`` opener
      # through the trailing ``rustup toolchain link`` line) so the
      # script exits cleanly after verifying ``./platform-tools/rust/
      # bin/rustc --version`` succeeds.
      install_sh="$out/share/cargo-build-sbf/sbf/scripts/install.sh"
      # Sanity-check the markers exist so we fail at build time if
      # the upstream script layout changes.
      grep -q '^  if \[\[ "''${BASH_VERSINFO\[0\]}" -lt 4 \]\]; then$' "$install_sh"
      grep -q '^  rustup toolchain link "$rust_version-sbpf-solana-$tools_version" platform-tools/rust$' "$install_sh"
      # Delete inclusive range from the BASH_VERSINFO opener through
      # the trailing ``rustup toolchain link ...`` line.  Use sed's ``d``
      # rather than ``c\`` because the latter takes a multi-line
      # replacement, and putting the replacement text on a less-indented
      # line in this nix multiline string would shrink the common-prefix
      # whitespace stripping (nix strips the *minimum* indentation from
      # every line of the string).  When that happened the cat-heredoc
      # below ended up with 4 leading spaces on every line -- in
      # particular the shebang ``    #!/nix/store/.../bash`` -- which
      # the kernel does not recognise as a shebang.  The wrapper file
      # was then written without the ``+x`` mode-bit, so the dev shell
      # fell through to a non-executable wrapper and ``cargo build-sbf``
      # observed ``error: no such command: build-sbf`` on CI.
      sed -i '/^  if \[\[ "''${BASH_VERSINFO\[0\]}" -lt 4 \]\]; then$/,/^  rustup toolchain link "\$rust_version-sbpf-solana-\$tools_version" platform-tools\/rust$/d' "$install_sh"

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
      # ``c`` and ``env.sh`` are stable helpers -- safe to symlink.
      for helper in c env.sh; do
        target="\$sdk_dir/\$helper"
        if [ ! -e "\$target" ]; then
          ln -s "$out/share/cargo-build-sbf/sbf/\$helper" "\$target"
        fi
      done
      # ``scripts/`` must be a real directory rather than a symlink to
      # the nix store.  install.sh's first lines are::
      #
      #   mkdir -p "\$(dirname "\$0")"/../dependencies
      #   cd "\$(dirname "\$0")"/../dependencies
      #
      # When \$0 is invoked as ``\$sdk_dir/scripts/install.sh`` and
      # ``scripts`` is a symlink to ``<nix-store>/.../sbf/scripts``, the
      # kernel resolves ``scripts/..`` to ``<nix-store>/.../sbf`` and
      # tries to ``mkdir ../dependencies`` inside the read-only nix
      # store -- aborting with ``Read-only file system``.  Materialise
      # ``scripts/`` as a real directory of per-file symlinks instead,
      # so ``scripts/..`` resolves logically to \$sdk_dir.
      mkdir -p "\$sdk_dir/scripts"
      for s in "$out/share/cargo-build-sbf/sbf/scripts"/*; do
        target="\$sdk_dir/scripts/\$(basename "\$s")"
        if [ ! -e "\$target" ]; then
          ln -s "\$s" "\$target"
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
      # Always recreate the symlink unconditionally.  Two earlier
      # attempts at conditional replacement -- "only if not a symlink",
      # then "only if not pointing at \$nix_pt" -- both ran into edge
      # cases where the runner's pre-existing state (real directory
      # from an upstream install_if_missing tarball download; or a
      # broken/stale symlink whose ``readlink`` matched a previous
      # derivation hash that no longer existed) caused the path to
      # be left alone, so subsequent execution hit an unpatched
      # ``rust/bin/rustc`` and failed with::
      #
      #   Could not start dynamically linked executable: .../v1.52/
      #   platform-tools/rust/bin/rustc
      #   NixOS cannot run dynamically linked executables intended for
      #   generic linux environments out of the box.
      #
      # The cost of unconditional rm + ln on every cargo-build-sbf
      # invocation is two cheap fs syscalls on a path the wrapper
      # owns; the win is a hard guarantee that downstream sees a
      # symlink to the autoPatchelf'd nix-store toolchain rather
      # than whatever leftover state the runner had.
      rm -rf "\$link"
      ln -s "\$nix_pt" "\$link"

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
      # Hardcode RUSTC to the nix store path directly rather than
      # going through the ``~/.cache/solana/v1.52/platform-tools``
      # symlink we just created.  Two CI runs in a row (aa292f7d and
      # the one before it) produced the same error
      # ``Provided "rustc" does not have sbpf-solana-solana target.``
      # The literal ``"rustc"`` (no path) in that message comes from
      # ``check_solana_target_installed``'s ``env::var("RUSTC")
      # .unwrap_or("rustc".to_owned())`` -- so RUSTC was empty when
      # cargo-build-sbf ran.  That can only mean the wrapper's
      # previous ``[ -x \$tools_rustc ]`` guard returned false, even
      # though locally on NixOS the symlinked rustc is executable and
      # the check passes.  Whatever runner-side state broke the test
      # (race vs. the ln -s above, leftover broken symlink, etc.)
      # disappears when we skip the cache lookup entirely and reach
      # for the nix-store path that's an actual build input to this
      # derivation.
      export RUSTC="${solana-platform-tools}/rust/bin/rustc"

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
