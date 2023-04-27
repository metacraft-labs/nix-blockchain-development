{pkgs}:
with pkgs; let
  example-container =
    nix2container.buildImage
    {
      name = "example";
      tag = "latest";
      config = {
        entrypoint = ["${pkgs.lib.getExe pkgs.figlet}" "MCL"];
      };
    };
in
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

        metacraft-labs.go-opera

        metacraft-labs.go-ethereum-capella

        # Test nix2container
        example-container.copyToDockerDaemon
      ]
      ++ lib.optionals (stdenv.hostPlatform.isx86) [
        metacraft-labs.rapidsnark
      ]
      ++ lib.optionals (stdenv.hostPlatform.isx86 && stdenv.isLinux) [
        # Rapidsnark depends on Pistache, which supports only Linux, see
        # https://github.com/pistacheio/pistache/issues/6#issuecomment-242398225
        # for more information
        metacraft-labs.rapidsnark-server
      ]
      ++ lib.optionals (!stdenv.isDarwin) [
        # Solana is still not compatible with macOS on M1
        metacraft-labs.solana
        # metacraft-labs.wasmd

        # Disabled until elrond-go can build with Go >= 1.19
        # Elrond
        metacraft-labs.cryptography36
        # metacraft-labs.erdpy
        # metacraft-labs.elrond-go
        # metacraft-labs.elrond-proxy-go

        # EOS
        metacraft-labs.leap
        metacraft-labs.eos-vm
        metacraft-labs.cdt

        # Ethereum
        metacraft-labs.nimbus
      ];

    shellHook = ''
      figlet -w$COLUMNS "nix-blockchain-development"
    '';
  }
