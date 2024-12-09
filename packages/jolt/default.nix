{ rust-bin,
  craneLib-nightly,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  openssl,
}:
let
  commonArgs = rec {
    pname = "jolt";
    version = "unstable-2024-12-04";

    nativeBuildInputs = [
      pkg-config
      openssl
    ];

    preBuild = ''
      sed -i 's/%2F/\//g' $CARGO_HOME/config.toml
    '';

    src = fetchFromGitHub {
      owner = "a16z";
      repo = "jolt";
      rev = "1c5fad8a0857f9599a668336d57537f2dd61e68b";
      hash = "sha256-VIFUqX5iTUyn+H0RgqmbXhvqkVI/akE9Ar/A33GuwDs=";
      fetchSubmodules = true;
    };
  };

  craneLib = craneLib-nightly.overrideToolchain (rust-bin.fromRustupToolchainFile
    (fetchurl {
      url =
      "https://raw.githubusercontent.com/${commonArgs.src.owner}/${commonArgs.src.repo}/${commonArgs.src.rev}/rust-toolchain.toml";
      hash = "sha256-Fyj+Bp/dt3epuTN9kXN+r7Z3gzXYCDrcVEPWTr1sQqk=";
    }));

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // rec {
      inherit cargoArtifacts;

      installPhaseCommand = ''
        cp -r /build/source/. $out
      '';

      doCheck = false;
    })
