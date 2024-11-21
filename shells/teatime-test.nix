{
  self',
  pkgs,
  ...
}:
pkgs.mkShell {
  packages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [self'.packages.teatime]))
  ];
}
