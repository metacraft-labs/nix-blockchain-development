{ stdenv,
  fetchGitHubReleaseAsset,
  autoPatchelfHook,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  name = "risc0-rust";
  version = "0.1.81.0";

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
    owner = "risc0";
    repo = "rust";
    tag  = "r${version}";
    asset = "rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-CzeZKT5Ubjk9nZZ2I12ak5Vnv2kFQNuueyzAF+blprU=";
  };
}
