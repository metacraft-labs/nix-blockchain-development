{pkgs}:
with pkgs;
  mkShell {
    packages = [
      # For priting the direnv banner
      figlet

      # For formatting Nix files
      alejandra
    ];

    shellHook = ''
      figlet "nix-blockchain-development"
    '';
  }
