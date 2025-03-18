{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
    ./all-packages.nix
  ];
  perSystem =
    {
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    let
      rust-stable =
        with inputs'.fenix.packages;
        with stable;
        combine [
          cargo
          clippy
          rust-analyzer
          rust-src
          rustc
          rustfmt
          targets.wasm32-unknown-unknown.stable.rust-std
          targets.wasm32-wasip1.stable.rust-std
          targets.wasm32-wasip2.stable.rust-std
        ];

      rust-latest =
        with inputs'.fenix.packages;
        with latest;
        combine [
          cargo
          clippy
          rust-analyzer
          rust-src
          rustc
          rustfmt
          targets.wasm32-unknown-unknown.latest.rust-std
          targets.wasm32-wasip1.latest.rust-std
          targets.wasm32-wasip2.latest.rust-std
        ];

      craneLib = inputs.crane.mkLib pkgs;
      craneLib-fenix-stable = craneLib.overrideToolchain rust-stable;
      craneLib-fenix-latest = craneLib.overrideToolchain rust-latest;

      cardano-node = builtins.getFlake "github:input-output-hk/cardano-node/f0b4ac897dcbefba9fa0d247b204a24543cf55f6";

      reexportedPackages = {
        ethereum_nix =
          {
            # geth = inputs'.ethereum_nix.packages.geth; # TODO: re-enable when flake show/check passes
          }
          // lib.optionalAttrs (pkgs.hostPlatform.isx86 && pkgs.hostPlatform.isLinux) {
            # nimbus = inputs'.ethereum_nix.packages.nimbus-eth2; # TODO: re-enable when flake show/check passes
          };
        # noir = {
        #   nargo = inputs'.noir.packages.nargo;
        #   noirc_abi_wasm = inputs'.noir.packages.noirc_abi_wasm;
        #   acvm_js = inputs'.noir.packages.acvm_js;
        # };
      };

      disabledPackages = [
        "circ"
        "leap"
        "go-opera"
      ];
    in
    rec {
      packages = self'.legacyPackages.metacraft-labs;

      checks =
        (builtins.removeAttrs self'.legacyPackages.metacraft-labs disabledPackages)
        // reexportedPackages.ethereum_nix;
      # // reexportedPackages.noir;

      overlayAttrs = {
        inherit (self'.legacyPackages) metacraft-labs nix2container noir;
      };

      legacyPackages = {
        inherit (inputs'.nix2container.packages) nix2container;

        inherit (cardano-node.outputs.packages.${system}) cardano-node cardano-cli;

        noir = inputs'.noir.packages;
        ethereum_nix = inputs'.ethereum_nix.packages;

        inherit
          rust-stable
          rust-latest
          craneLib
          craneLib-fenix-stable
          craneLib-fenix-latest
          ;

        rustPlatformStable = pkgs.makeRustPlatform {
          rustc = rust-stable;
          cargo = rust-stable;
        };
        rustPlatformNightly = pkgs.makeRustPlatform {
          rustc = rust-latest;
          cargo = rust-latest;
        };
      };
    };
}
