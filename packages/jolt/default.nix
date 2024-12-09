{ rust-bin,
  craneLib-nightly,
  fetchFromGitHub,
  fetchGitHubFile,
  pkg-config,
  openssl,
  ...
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
      sed -i 's|package =.*git = "https://github.com/a16z/jolt"|path = "'$out'"|' src/main.rs
    '';

    src = fetchFromGitHub {
      owner = "a16z";
      repo = "jolt";
      rev = "1c5fad8a0857f9599a668336d57537f2dd61e68b";
      hash = "sha256-VIFUqX5iTUyn+H0RgqmbXhvqkVI/akE9Ar/A33GuwDs=";
      fetchSubmodules = true;
    };
  };

  rust-toolchain = rust-bin.fromRustupToolchainFile
    (fetchGitHubFile {
      inherit commonArgs;
      file = "rust-toolchain.toml";
      hash = "sha256-Fyj+Bp/dt3epuTN9kXN+r7Z3gzXYCDrcVEPWTr1sQqk=";
    });
  craneLib = craneLib-nightly.overrideToolchain rust-toolchain;
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // rec {
      inherit cargoArtifacts;

      installPhaseCommand = ''
        cp -r /build/source/. $out
        mkdir -p $out/bin; cp target/release/jolt $out/bin/

        # Add cargo (and similar) commands to bin output, so
        # nix shell [flake path]#jolt
        # gives you everything needed to create and work with a jolt-powered
        # projects.
        ln -s "${rust-toolchain}"/bin/* $out/bin/
      '';

      doCheck = false;
    })
