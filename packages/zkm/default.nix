{
  zkm-rust,
  craneLib,
  fetchFromGitHub,
  installSourceAndCargo,
  fetchzip,
  pkg-config,
  openssl,
  buildGoModule,
  ...
}:
let
  commonArgs = rec {
    pname = "zkm";
    version = "0-unstable-2025-04-10";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    # https://crane.dev/faq/no-cargo-lock.html
    cargoLock = ./Cargo.lock;

    src = fetchFromGitHub {
      owner = "zkMIPS";
      repo = "zkm";
      rev = "eb09cf6c81bed9717bc98e4a4c9a61f54787a351";
      hash = "sha256-3aIdoe1R9wAM2OMRK2BFVD9zXChNRN8eS8NmTlTeggo=";
    };
  };

  zkm_libsnark = buildGoModule rec {
    pname = "zkmgnark";

    inherit (commonArgs) version src;

    sourceRoot = "${src.name}/recursion/src/snark/libsnark";

    vendorHash = "sha256-zZNyMW0KGBtk8k4bW8UP9LAar+ZLfJCdrCYOp5u8osc=";

    # Taken from
    # https://github.com/zkMIPS/zkm/blob/b8014509756b34bb92f90301801d67e7a3645094/recursion/build.rs#L9-L21
    CGO_ENABLED = 1;
    buildPhase = ''
      go build -tags=debug -o ./lib${pname}.a -buildmode=c-archive .
    '';

    installPhase = ''
      mkdir -p "$out"/lib
      mv ./lib${pname}.a "$out"/lib/
    '';
  };

  rust-toolchain = zkm-rust;
  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    preBuild = ''
      export HOME=$PWD

      export OUT_DIR="${zkm_libsnark}/lib" RUSTFLAGS="$RUSTFLAGS -L ${zkm_libsnark}/lib"
      sed -i '9,24d' recursion/build.rs
    '';

    postInstall = ''
      mkdir -p "$out"/lib
      ln -s "${zkm_libsnark}"/lib/* "$out"/lib

      rm "$out"/bin/cargo
      cat <<EOF > "$out"/bin/cargo
      #!/usr/bin/env sh
      : \''${RUST_LOG:=info}
      : \''${BASEDIR:='$out'}
      : \''${SEG_SIZE:=65536}
      : \''${ARGS:='2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 hello'}
      : \''${SEG_OUTPUT:='/tmp/output'}
      : \''${SEG_FILE_DIR:='/tmp/output'}
      LD_LIBRARY_PATH="\''${LD_LIBRARY_PATH-}:${openssl.out}/lib"
      export RUST_LOG BASEDIR SEG_SIZE ARGS SEG_OUTPUT SEG_FILE_DIR LD_LIBRARY_PATH
      ${rust-toolchain}/bin/cargo \$@
      EOF
      chmod +x "$out"/bin/cargo
    '';

    doCheck = false;
  }
)
