{ pkgs, config, ... }:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    jq
    nix-eval-jobs
  ];

  shellHook =
    ''
      figlet -w$COLUMNS "nix-blockchain-development"
    ''
    + config.pre-commit.installationScript;
}
