{
  stdenv,
  fetchGitHubReleaseAsset,
  autoPatchelfHook,
  zlib,
  openssl,
  ...
}:
stdenv.mkDerivation rec {
  name = "zkm-rust";
  version = "20250224";

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./rust-toolchain*/* $out/
    runHook postInstall
  '';

  src = fetchGitHubReleaseAsset {
    owner = "zkMIPS";
    repo = "toolchain";
    tag = "${version}";
    asset = "rust-toolchain-x86-64-unknown-linux-gnu-${version}.tar.xz";
    hash = "sha256-smQXVZY7CqfWKyEj41V+jJGnfu/K+JL6t93LVwLOu4I=";
  };
}
