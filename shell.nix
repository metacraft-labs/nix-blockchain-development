{pkgs}:
with pkgs;
  mkShell {
    packages = [
      # For priting the direnv banner
      figlet

      # For formatting Nix files
      alejandra

      nodejs-14_x

      # Packages defined in this repo
      ## Blockchain pkgs
      metacraft-labs.solana
      metacraft-labs.cosmos-theta-testnet
      metacraft-labs.snowbridge-relayer

      ## Misc tools
      metacraft-labs.abigen
    ];

    inputsFrom = [
      metacraft-labs.solana
      metacraft-labs.snowbridge-relayer
      metacraft-labs.snowbridge-parachain
    ];

    CGO_ENABLED = 0;
    CARGO_INCREMENTAL = 0;
    RUST_BACKTRACE = 1;
    RUSTFLAGS = "-C debuginfo=1";
    PROTOC = "${protobuf}/bin/protoc";
    LIBCLANG_PATH = "${libclang.lib}/lib";

    shellHook = ''
      figlet -w$COLUMNS "nix-blockchain-development"
    '';
  }
