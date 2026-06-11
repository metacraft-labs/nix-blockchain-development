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
  rustup,
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

    # cargo-build-sbf has three read-only-filesystem / missing-tool
    # hazards when run from a nix store path inside a nix dev shell:
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
    # 3. After install_if_missing, the binary calls
    #    ``link_solana_toolchain`` which spawns ``rustup toolchain list
    #    -v`` to discover the existing solana toolchain and
    #    ``rustup toolchain link <name> <path>`` to register the
    #    downloaded platform-tools rust as a +solana override.  The nix
    #    dev shell has no rustup on PATH, so the binary aborts with
    #    ``Failed to execute rustup: No such file or directory
    #    (os error 2)``.
    #
    # Move the vendored helpers to ``$out/share/cargo-build-sbf/sbf``
    # (immutable reference) and wrap the binary so it materialises a
    # writable mirror at ``$HOME/.cache/solana/cargo-build-sbf-sdk``
    # (symlinks for the read-only helpers, real directory for
    # ``dependencies/``) on first invocation, points ``SBF_SDK_PATH``
    # there, and prepends ``rustup`` from the nix store onto ``PATH``
    # so install_if_missing's rustup spawns succeed.  Subsequent
    # invocations just reuse the cached writable mirror.
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

      # link_solana_toolchain spawns ``rustup toolchain list -v`` to
      # register the downloaded platform-tools rust as a +solana
      # override.  Make sure rustup is on PATH so that the spawn
      # succeeds.
      export PATH="${rustup}/bin:\$PATH"

      exec "$out/bin/.cargo-build-sbf-unwrapped" "\$@"
      EOF
      chmod +x "$out/bin/cargo-build-sbf"
    '';
  }
)
