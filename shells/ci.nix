{ pkgs, config, ... }:
let
  # git-hooks.nix installs `.pre-commit-config.yaml` and git hooks into
  # `git rev-parse --show-toplevel` of the directory the shell is entered
  # from, so `nix develop /path/to/this-repo#ci` run inside another checkout
  # would plant this repository's hooks there. `ownRepoOnly` runs a snippet
  # only when that toplevel is this repository, recognised by a `flake.nix`
  # identical to the one this shell was evaluated from; anything it cannot
  # establish counts as another repository, so it fails safe.
  # tests/test_dev_shell_writes_nothing_elsewhere.sh
  ownRepoOnly = script: ''
    _own_repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || true)"
    if [ -n "$_own_repo_root" ] && [ -f "$_own_repo_root/flake.nix" ] \
      && [ "$(${pkgs.coreutils}/bin/sha256sum "$_own_repo_root/flake.nix" | ${pkgs.coreutils}/bin/cut -d' ' -f1)" \
        = "${builtins.hashFile "sha256" ../flake.nix}" ]; then
    ${script}
    fi
    unset _own_repo_root
  '';
in
pkgs.mkShellNoCC {
  packages = with pkgs; [
    jq
    nix-eval-jobs
    figlet
  ];

  shellHook = ''
    figlet -w"''${COLUMNS:-80}" "nix-blockchain-development"
  ''
  + ownRepoOnly config.pre-commit.installationScript;
}
