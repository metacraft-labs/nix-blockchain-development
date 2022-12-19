{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay ./all-packages.nix];
  perSystem = {
    self',
    inputs',
    pkgs,
    ...
  }: let
    rust-overlay = inputs.rust-overlay.overlays.default;
    pkgs-extended = pkgs.extend rust-overlay;
    craneLib-stable = (inputs.crane.mkLib pkgs).overrideToolchain rust-stable;
    rust-stable = pkgs-extended.rust-bin.stable.latest.default.override {
      extensions = ["rust-src"];
      targets = ["wasm32-wasi" "wasm32-unknown-unknown"];
    };
  in {
    packages = self'.legacyPackages.metacraft-labs;

    overlayAttrs = {
      inherit (self'.legacyPackages) metacraft-labs nix2container;
    };

    legacyPackages = {
      nix2container = inputs'.nix2container.packages.nix2container;
      inherit (inputs'.cardano-node.packages) cardano-node cardano-cli;

      inherit rust-stable craneLib-stable;

      rustPlatformStable = pkgs.makeRustPlatform {
        rustc = rust-stable;
        cargo = rust-stable;
      };
    };
  };
}
