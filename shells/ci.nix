{ pkgs, config, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    jq
    nix-eval-jobs
    figlet
  ];

  shellHook = ''
    figlet -w"''${COLUMNS:-80}" "nix-blockchain-development"
  ''
  + config.pre-commit.installationScript;
}
