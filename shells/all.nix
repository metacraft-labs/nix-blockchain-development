{
  pkgs,
  self',
}:
with pkgs;
let
  example-container = nix2container.buildImage {
    name = "example";
    tag = "latest";
    config = {
      entrypoint = [
        "${pkgs.figlet}/bin/figlet"
        "MCL"
      ];
    };
  };
in
mkShell {
  packages = [
    # For priting the direnv banner
    figlet

    # For formatting Nix files
    alejandra

    # Packages defined in this repo
    self'.packages.cosmos-theta-testnet
    self'.packages.circom

    self'.packages.circ

    self'.packages.go-opera

    self'.packages.polkadot
    self'.packages.polkadot-fast

    # noir
    # self'.legacyPackages.noir.nargo
    # self'.legacyPackages.noir.noirc_abi_wasm
    # self'.legacyPackages.noir.acvm_js

    # ethereum.nix
    self'.legacyPackages.ethereum_nix.geth

    # avalanche cli
    self'.packages.avalanche-cli

    # Node.js related
    self'.packages.corepack-shims
  ]
  ++ lib.optionals (stdenv.hostPlatform.isx86) [
    self'.packages.rapidsnark

    # Cardano
    self'.packages.cardano
  ]
  ++ lib.optionals (stdenv.hostPlatform.isx86 && stdenv.hostPlatform.isLinux) [
    # Rapidsnark depends on Pistache, which supports only Linux, see
    # https://github.com/pistacheio/pistache/issues/6#issuecomment-242398225
    # for more information
    self'.packages.rapidsnark-server

    # Ethereum
    self'.legacyPackages.ethereum_nix.nimbus

    # Test nix2container
    example-container.copyToDockerDaemon
  ]
  ++ lib.optionals (!stdenv.isDarwin) [
    # Solana is still not compatible with macOS on M1
    # self'.packages.solana
    self'.packages.wasmd

    # Disabled until elrond-go can build with Go >= 1.19
    # Elrond
    # self'.packages.elrond-go
    # self'.packages.elrond-proxy-go

    # EOS
    self'.packages.leap
    self'.packages.eos-vm
    self'.packages.cdt

    # emscripten
    self'.packages.emscripten
  ];

  shellHook = ''
    figlet -w$COLUMNS "nix-blockchain-development"
  '';
}
