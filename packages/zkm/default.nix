{
  zkm-rust,
  craneLib-nightly,
  fetchFromGitHub,
  installSourceAndCargo,
  fetchzip,
  pkg-config,
  openssl,
  ...
}:
let
  commonArgs = rec {
    pname = "zkm";
    version = "0-unstable-2025-03-12";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    # https://crane.dev/faq/no-cargo-lock.html
    cargoLock = ./Cargo.lock;

    src = fetchFromGitHub {
      owner = "zkMIPS";
      repo = "zkm";
      rev = "7d40b91e991c889537b76ac8949ba850511caeaf";
      hash = "sha256-ZpxF9kwhV3BqWb0M6PJR+D2Lk26BtCGcjskPiIbgZkE=";
    };
  };

  rust-toolchain = zkm-rust;
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    preBuild = ''
      export HOME=$PWD
    '';

    cargoBuildCommand = "cargo build --release -p zkm-runtime -p zkm-emulator -p zkm-prover -p zkm-build";

    postInstall = ''
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
