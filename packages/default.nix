{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay ./all-packages.nix];
  perSystem = {
    self',
    ...
  }: {
    packages = self'.legacyPackages.metacraft-labs;

    overlayAttrs = {
      inherit (self'.legacyPackages) metacraft-labs;
    };
  };
}
