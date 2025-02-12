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
  version = "20250108";

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
    hash = "sha256-lPSAKd9eolXBd32sXB9qhs+fUPJLJ5QROG6P3wS5uik=";
  };
}
