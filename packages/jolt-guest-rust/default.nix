{
  stdenv,
  fetchGitHubReleaseAsset,
  autoPatchelfHook,
  zlib,
  ...
}:
let
  nightly-hash = "8af9d45d5e09a04832cc9b2e1df993fd1ce49d02";
in
stdenv.mkDerivation rec {
  name = "jolt-guest-rust"; # Used when guest is compiled with std
  version = "nightly-${nightly-hash}";

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
    owner = "a16z";
    repo = "rust";
    tag = "${version}";
    asset = "rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-aAhqLAvbeIh60R/E1c85KxWmYDH2SOpXhQChW3y3wgQ=";
  };
}
