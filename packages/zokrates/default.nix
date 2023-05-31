{
  lib,
  fetchgit,
  pkgs,
  rustPlatform,
}:
with pkgs;
  rustPlatform.buildRustPackage rec {
    pname = "zokrates";
    version = "0.8.7";
    cargoBuildFlags = "-p zokrates_cli";

    src = fetchgit {
      url = "https://github.com/Zokrates/ZoKrates.git";
      rev = "0.8.7";
      hash = "sha256-Ew7MYJg3Mxz05ngL0sZEuPijxzaHhliK9GIho1GTFr8=";
    };

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "ark-marlin-0.3.0" = "sha256-dc4StG8FEDrxVuo00M/uF6SRi5rpTx4I2PnmKtVJTLI=";
        "phase2-0.2.2" = "sha256-eONGJEK6g2DN6dKL86vMVx/Md63u5E2Qzv4tpek0NzM=";
      };
    };

    nativeBuildInputs = [pkg-config];
    PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

    buildInputs = [];
  }
