{ rust-bin,
  craneLib-nightly,
  fetchFromGitHub,
  installSourceAndCargo,
  fetchzip,
  pkg-config,
  openssl,
  ...
}:
let
  # musl.cc don't provide versioning, so this archive could change at any time.
  # It could be replaced with somethng like pkgsCross.mips-linux-gnu.gcc11.
  # However, package building time increases by a lot, I think the gcc paths are
  # hard-coded so patching/symlinking will need to be done and to top it all off,
  # after ~14 minutes of compilation, gcc11 failed to build.
  # It hasn't changed since 2021, so it's probably fine to leave for now.
  mips-musl = fetchzip {
    url = "http://musl.cc/mips-linux-muslsf-cross.tgz";
    hash = "sha256-aUp+UJgyisJu5PXTktuw1kWsTevNm0BX3qOt2eEO4EY=";
  };

  commonArgs = rec {
    pname = "zkm";
    version = "unstable-2024-12-04";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    # https://crane.dev/faq/no-cargo-lock.html
    cargoLock = ./Cargo.lock;

    src = fetchFromGitHub {
      owner = "zkMIPS";
      repo = "zkm";
      rev = "08629aecb2e87aa752755c91193e5860fe6c8ee7";
      hash = "sha256-Zquqe41LJuAnfLCjk1e3D6dnKLgGTaMRJaw5Ww+ykrQ=";
    };
  };

  rust-toolchain = rust-bin.nightly."2024-10-09".default;
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // (installSourceAndCargo rust-toolchain)
    // rec {
      inherit cargoArtifacts;

      postInstall = let
        variables = ''
          : \''${RUST_LOG:=info}
          : \''${BASEDIR:='$out'}
          : \''${SEG_SIZE:=65536}
          : \''${ARGS:='2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 hello'}
          : \''${SEG_OUTPUT:='/tmp/output'}
          : \''${SEG_FILE_DIR:='/tmp/output'}
          export RUST_LOG BASEDIR SEG_SIZE ARGS SEG_OUTPUT SEG_FILE_DIR
        '';

        # Prebuilt binaries for mips-unknown-linux-musl target seem to have
        # silently been stopped. I couldn't find an official post or issue/pr
        # about it, but from experimenting this is the last nightly build which
        # includes it.
        guest-toolchain = rust-bin.nightly."2023-10-09".default.override {
          targets = [ "mips-unknown-linux-musl" ];
        };
      in ''
        cat <<EOF >> "$out"/.cargo-config
        [target.mips-unknown-linux-musl]
        linker = "${mips-musl}/bin/mips-linux-muslsf-gcc"
        rustflags = ["--cfg", 'target_os="zkvm"',"-C", "target-feature=+crt-static", "-C", "link-arg=-g"]
        EOF

        cat <<EOF > "$out"/bin/cargo_guest
        #!/usr/bin/env sh
        ${variables}
        export PATH="${guest-toolchain}/bin:\$PATH"
        cargo --config "$out/.cargo-config" \$@
        EOF

        cat <<EOF > "$out"/bin/cargo_host
        #!/usr/bin/env sh
        ${variables}
        export PATH="${rust-toolchain}/bin:\$PATH"
        cargo \$@
        EOF

        chmod +x "$out"/bin/cargo_guest "$out"/bin/cargo_host
      '';

      doCheck = false;
    })
