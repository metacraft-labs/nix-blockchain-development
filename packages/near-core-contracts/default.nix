{
  fetchFromGitHub,
  lib,
  rust-bin,
  makeRustPlatform,
  pkg-config,
  openssl,
}: let
  rustVersion = "1.61.0";

  wasmTarget = "wasm32-unknown-unknown";

  rustWithWasmTarget = rust-bin.stable.${rustVersion}.default.override {
    targets = [wasmTarget];
  };

  rustPlatformWasm = makeRustPlatform {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };
in
  (rustPlatformWasm.buildRustPackage {
    pname = "near-core-contracts";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "near";
      repo = "core-contracts";
      rev = "dad58eb5f968c25913e746028ad63980506f5890";
      sha256 = "sha256-kgMNK0WLFiVdjOM1NGAjuEhtAn4ahigfTVLjdPK0bos=";
    };

    sourceRoot = "staking-pool";

    cargoSha256 = lib.fakeSha256;

    nativeBuildInputs = [pkg-config];
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

    phases = ["buildPhase"];

    buildPhase = ''
      cargo build --release --target=wasm32-unknown-unknown
    '';
    installPhase = ''
      mkdir -p $out/lib
      cp target/wasm32-unknown-unknown/release/*.wasm $out/lib/
    '';
  })
  .overrideAttrs (old: {
    preUnpack = ''
      echo HEERERERER
    '';
  })
