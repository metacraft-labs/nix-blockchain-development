{ risc0-rust,
  craneLib-nightly,
  fetchurl,
  fetchFromGitHub,
  installSourceAndCargo,
  pkg-config,
  openssl,
  autoPatchelfHook,
  ...
}:
let
  recursion-zkr = let
    hash' = "ffc503386276f809137161f18d2f3ddcba3bb4b2d8b5d893b2c5d94b35afaf47";
  in fetchurl rec {
    url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${hash'}.zip";
    hash = "sha256-/8UDOGJ2+AkTcWHxjS893Lo7tLLYtdiTssXZSzWvr0c=";
  };

  commonArgs = rec {
    pname = "risc0";
    version = "unstable-2024-12-12";

    nativeBuildInputs = [
      pkg-config
      openssl
      autoPatchelfHook
    ];

    src = fetchFromGitHub {
      owner = "risc0";
      repo = "risc0";
      rev = "b33c13fd22f9a07afa11edc969c56aad22dcbd53";
      hash = "sha256-cCqEum/HU0cGIxm2V3cPirRM5H1eDWuiaR1sGAzuPTk=";
    };
  };

  rust-toolchain = risc0-rust;
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // (installSourceAndCargo rust-toolchain)
    // rec {
      inherit cargoArtifacts;

      postPatch = ''
        # Replace usages of `Command::new("rustup")` with the correct value
        # which should be used
        sed -i '82,89d;90ilet path_raw = Some("${rust-toolchain}");' risc0/cargo-risczero/src/toolchain.rs
        sed -i '410,417d;663,681d;418ilet rustc = "${rust-toolchain}/bin/rustc";' risc0/build/src/lib.rs
        # Fix starter template
        sed -i 's|{{ risc0_build }}|path = "'$out'"|' risc0/cargo-risczero/templates/rust-starter/methods/Cargo-toml
        sed -i 's|{{ risc0_zkvm }}|path = "'$out'"|' risc0/cargo-risczero/templates/rust-starter/host/Cargo-toml
      '';

      preBuild = ''
        export RECURSION_SRC_PATH="${recursion-zkr}" RUSTFLAGS="$RUSTFLAGS -A dead_code"
      '';

      cargoBuildCommand = "cargo build --release -p risc0-zkvm -p risc0-build -p cargo-risczero";

      doCheck = false;
    })
