{
  stdenv,
  fetchGitHubReleaseAsset,
  autoPatchelfHook,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  name = "risc0-rust";
  version = "1.81.0";

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r ./* "$out/"

    # This is needed because RISC0 expects a toolchain directory, which contains
    # risc0 rust versions in folders, following a specific naming scheme
    # https://github.com/risc0/risc0/blob/0181c41119cf14e3f0f302e5ede1f20f6a1f81ce/rzup/src/paths.rs#L102-L142
    # Circumventing the toolchain directory (and overall the forced ~/.risc0 path)
    # is done by patching the codebase in the risc0 package.
    # Result is copied, not symlinked, in case risc0 iterates all subdirectories.
    mkdir -p "$out/r0.${version}-risc0-rust-x86_64-unknown-linux-gnu"
    cp -r ./* "$out/r0.${version}-risc0-rust-x86_64-unknown-linux-gnu"

    runHook postInstall
  '';

  src = fetchGitHubReleaseAsset {
    owner = "risc0";
    repo = "rust";
    tag = "r0.${version}";
    asset = "rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-CzeZKT5Ubjk9nZZ2I12ak5Vnv2kFQNuueyzAF+blprU=";
  };
}
