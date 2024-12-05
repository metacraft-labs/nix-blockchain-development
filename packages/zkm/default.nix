{ clang,
  lld,
  cmake,
  rust-bin,
  craneLib-nightly,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  pkg-config,
  openssl,
}:
let
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

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  craneLib = craneLib-nightly.overrideToolchain rust-bin.nightly."2024-10-09".default;
in
  craneLib.buildPackage (commonArgs
    // rec {
      inherit cargoArtifacts;

      doCheck = false;
    })
