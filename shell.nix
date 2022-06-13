{pkgs}:
with pkgs;
  mkShell {
    buildInputs = [
      # For priting the direnv banner
      figlet

      # For formatting Nix files
      alejandra

      # For an easy way to launch all required blockchain simulations
      # and tailed log files
      tmux
      tmuxinator
      metacraft-labs.solana
    ];

    shellHook = ''
      figlet "nix-blockchain-development"
      echo "${metacraft-labs.solana}"
    '';
  }
