{
  stdenv,
  fetchGitHubReleaseAsset,
  autoPatchelfHook,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  name = "sp1-rust";
  version = "1.82.0";

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./* $out/
    runHook postInstall
  '';

  src = fetchGitHubReleaseAsset {
    owner = "succinctlabs";
    repo = "rust";
    tag = "succinct-${version}";
    asset = "rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-wXI2zVwfrVk28CR8PLq4xyepdlu65uamzt/+jER2M2k=";
  };
}
