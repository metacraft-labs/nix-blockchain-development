{pkgs}:
with pkgs;
  mkShell {
    packages = [
      # For priting the direnv banner
      figlet

      # For formatting Nix files
      alejandra

      # Packages defined in this repo
      metacraft-labs.solana
      metacraft-labs.cosmos-theta-testnet
      metacraft-labs.nlvm
    ];

    shellHook = ''
      figlet -w$COLUMNS "nix-blockchain-development"
    '';
  }
