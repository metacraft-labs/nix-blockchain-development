{
  stdenv,
  fetchGitHubReleaseAsset,
  autoPatchelfHook,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  name = "sp1-rust";
  version = "1.81.0";

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
    tag = "v${version}";
    asset = "rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-aj55nDtUhD1A6y5jsZDw6B/2RaK5yjvIyZdn8LC65UY=";
  };
}
