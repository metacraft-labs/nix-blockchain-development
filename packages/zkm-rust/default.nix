{
  stdenv,
  fetchGitHubReleaseAsset,
  autoPatchelfHook,
  zlib,
  openssl,
  ...
}:
stdenv.mkDerivation rec {
  name = "risc0-rust";
  version = "20241217";

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
    hash = "sha256-XgR+nR5JwqGJ6Rx4cz65N2LTmGZDhBZ9ulXTIn5lW/Q=";
  };
}
