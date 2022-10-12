{pkgs}:
with pkgs;
  mkShell {
    packages =
      [
        # For priting the direnv banner
        figlet

        # For formatting Nix files
        alejandra

        # Packages defined in this repo
        metacraft-labs.cosmos-theta-testnet
        metacraft-labs.circom
        metacraft-labs.circ
      ]
      ++ lib.optionals (!stdenv.isDarwin) [
        # Solana is still not compatible with macOS on M1
        metacraft-labs.solana
        metacraft-labs.wasmd
      ];

    shellHook = ''
      figlet -w$COLUMNS "nix-blockchain-development"
    '';
  }
