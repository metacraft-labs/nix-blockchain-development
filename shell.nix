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

        # Disabled until cvc4 builds again
        # metacraft-labs.circ

        metacraft-labs.go-opera

        metacraft-labs.nimbus
      ]
      ++ lib.optionals (!stdenv.isDarwin) [
        # Solana is still not compatible with macOS on M1
        metacraft-labs.solana
        metacraft-labs.wasmd

        # Disabled until elrond-go can build with Go >= 1.19
        # Elrond
        # metacraft-labs.erdpy
        # metacraft-labs.elrond-go
        # metacraft-labs.elrond-proxy-go

        # EOS
        metacraft-labs.leap
        metacraft-labs.eos-vm
        metacraft-labs.cdt
      ];

    shellHook = ''
      figlet -w$COLUMNS "nix-blockchain-development"
    '';
  }
