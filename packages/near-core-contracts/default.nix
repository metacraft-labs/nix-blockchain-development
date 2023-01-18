{
  pkgs,
  stdenv,
  system,
  makeRustPlatform,
  rust-overlay,
  fetchgit,
}: let
  rustPkgs = import pkgs {
    inherit system;
    overlays = [(import rust-overlay)];
  };

  rustVersion = "1.61.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rustPkgs.rust-bin.stable.${rustVersion}.default.override {
    targets = [wasmTarget];
  };

  rustPlatformWasm = makeRustPlatform {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };

  common = {
    version = "0.0.1";

    nativeBuildInputs = [pkgs.pkg-config];
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  repo = fetchgit {
    url = "https://github.com/near/core-contracts";
    rev = "39e029619041b564ec08d33a8d65325b653b121b";
    # sha256 = lib.fakeSha256;
    sha256 = "sha256-J+zroK9C3mbLkn06c9t9VwLB785xRAMZslXm1mM3Rt0=";
  };
in {
  wasm = rustPlatformWasm.buildRustPackage (common
    // {
      pname = "near-core-contracts";
      version = "1.0.0";

      phases = ["buildPhase"];

      src = "${repo}/staking-pool";

      buildPhase = ''
        cargo build --release --target=wasm32-unknown-unknown
      '';
      installPhase = ''
        mkdir -p $out/lib
        cp target/wasm32-unknown-unknown/release/*.wasm $out/lib/
      '';
    });
}
