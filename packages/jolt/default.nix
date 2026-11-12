{
  rustFromToolchainFile,
  craneLib,
  fetchFromGitHub,
  installSourceAndCargo,
  pkg-config,
  openssl,
  jolt-guest-rust,
  ...
}:
let
  commonArgs = rec {
    pname = "jolt";
    version = "archive/fast-recursion-20260925-unstable-2026-11-12";

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
      rev = "e832d8bdd2b876c60f2bab3129bd4968c3efb3ed";
      hash = "sha256-E0UkqkawenU83eav9CSqnCBR3nbye9XApwyohL7eItQ=";
      fetchSubmodules = true;
    };
  };

  rust-toolchain = rustFromToolchainFile {
    dir = commonArgs.src;
    sha256 = "sha256-eRCZskam9/DrpAVsoMyvSY7TLnl0E5gfN8FK4gcgZBo=";
  };

  crane = craneLib.overrideToolchain rust-toolchain;
  cargoArtifacts = crane.buildDepsOnly commonArgs;
in
crane.buildPackage (
  commonArgs
  // (installSourceAndCargo rust-toolchain)
  // rec {
    inherit cargoArtifacts;

    postPatch = ''
      sed -i 's|package =.*git = "https://github.com/a16z/jolt"|path = "'$out'"|' src/main.rs
      sed -i '44,46d' jolt-core/src/host/toolchain.rs
    '';

    # Different toolchain is used when guest has std features
    # https://github.com/a16z/jolt/blob/fa45507aaddb1815bafd54332e4b14173a7f8699/jolt-core/src/host/mod.rs#L132-L134
    postInstall = ''
      rm $out/bin/cargo
      cat <<EOF > $out/bin/cargo
      #!/bin/sh
      if [ -n "\''${RUSTUP_TOOLCHAIN+x}" ]
      then
          export PATH="${jolt-guest-rust}/rust/build/host/stage2/bin:\$PATH"
      fi
      ${rust-toolchain}/bin/cargo \$@
      EOF
      chmod +x $out/bin/cargo
    '';

    doCheck = false;
  }
)
