{pkgs}:
with pkgs;
  rustPlatform.buildRustPackage {
    pname = "circ";
    version = "0.0";
    src = fetchgit {
      url = "https://github.com/circify/circ";
      sha256 = "sha256-Lu1GNTOQM3faEeMhmFX7F/GnfU35c0GgNMT6thoVZzs=";
    };

    cargoSha256 = "sha256-8iBvfpng0cQja8tiK6rk+a9DmoRy2pZtPXHfENgXZ8g=";

    nativeBuildInputs = with pkgs; [
      zlib
      gcc
      openssl
      cvc4
      cbc
      binutils
      gnum4
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mv target/x86_64-unknown-linux-gnu/release/examples/circ $out/bin

      runHook postInstall
    '';

    buildNoDefaultFeatures = true;
    buildFeatures = ["bls12381" "ff_dfl" "lang-c" "good_lp" "lp-solvers" "bellman" "rsmt2" "zokrates_parser" "zokrates_pest_ast"];

    meta = with lib; {
      homepage = "https://github.com/circify/circ";
      platforms = platforms.linux;
    };
  }
