{pkgs, ...}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    just
    jq
    nix-eval-jobs
  ];
}
