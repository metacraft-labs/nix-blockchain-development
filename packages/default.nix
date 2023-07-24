{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay ./all-packages.nix];
  perSystem = {
    self',
    inputs',
    pkgs,
    system,
    ...
  }: let
    pkgs-extended = let
      rust-overlay = inputs.rust-overlay.overlays.default;
    in
      pkgs.extend rust-overlay;

    rust-stable = pkgs-extended.rust-bin.stable.latest.default.override {
      extensions = ["rust-src"];
      targets = ["wasm32-wasi" "wasm32-unknown-unknown"];
    };
    rust-nightly = pkgs-extended.rust-bin.nightly.latest.default.override {
      extensions = ["rust-src"];
      targets = ["wasm32-wasi" "wasm32-unknown-unknown"];
    };

    craneLib-stable = (inputs.crane.mkLib pkgs).overrideToolchain rust-stable;
    craneLib-nightly = (inputs.crane.mkLib pkgs).overrideToolchain rust-nightly;

    cardano-node = builtins.getFlake "github:input-output-hk/cardano-node/f0b4ac897dcbefba9fa0d247b204a24543cf55f6";
  in {
    packages = self'.legacyPackages.metacraft-labs;

    overlayAttrs = {
      inherit (self'.legacyPackages) metacraft-labs nix2container noir;
    };

    legacyPackages = {
      inherit (inputs'.nix2container.packages) nix2container;

      inherit (cardano-node.outputs.packages.${system}) cardano-node cardano-cli;

      noir = inputs'.noir.packages;

      inherit rust-stable rust-nightly craneLib-stable craneLib-nightly;

      rustPlatformStable = pkgs.makeRustPlatform {
        rustc = rust-stable;
        cargo = rust-stable;
      };
      rustPlatformNightly = pkgs.makeRustPlatform {
        rustc = rust-nightly;
        cargo = rust-nightly;
      };
    };
  };
}
