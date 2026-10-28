{
  description = "nix-blockchain-development";

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  inputs = {
    nixos-modules.url = "github:metacraft-labs/devops-modules";

    nixpkgs.follows = "nixos-modules/nixpkgs";
    nixpkgs-unstable.follows = "nixos-modules/nixpkgs-unstable";
    flake-parts.follows = "nixos-modules/flake-parts";
    flake-utils.follows = "nixos-modules/flake-utils";
    flake-compat.follows = "nixos-modules/flake-compat";
    nix2container.follows = "nixos-modules/nix2container";
    crane.follows = "nixos-modules/crane";
    fenix.follows = "nixos-modules/fenix";
    ethereum_nix.follows = "nixos-modules/ethereum-nix";
    treefmt-nix.follows = "nixos-modules/treefmt-nix";
    devenv.follows = "nixos-modules/devenv";
  };

  outputs =
    inputs@{
      flake-parts,
      nixos-modules,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        nixos-modules.modules.flake.git-hooks
        ./packages
      ];
      flake.mcl.shard-matrix.systemsToBuild = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          self',
          config,
          system,
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          # These SDKs currently exist only on Linux. Four additionally use
          # upstream x86_64-only guest toolchains. zkWasm is deliberately absent:
          # its package is marked broken and cannot form an evaluable dev shell.
          devShells =
            pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (
              {
                nexus = import ./shells/nexus.nix { inherit pkgs self'; };
              }
              // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
                jolt = import ./shells/jolt.nix { inherit pkgs self'; };
                zkm = import ./shells/zkm.nix { inherit pkgs self'; };
                sp1 = import ./shells/sp1.nix { inherit pkgs self'; };
                risc0 = import ./shells/risc0.nix { inherit pkgs self'; };
              }
            )
            // {
              default = import ./shells/all.nix {
                inherit pkgs self';
              };
              ci = import ./shells/ci.nix {
                inherit pkgs config;
              };
              evm = import ./shells/evm.nix { inherit pkgs; };
              solana = import ./shells/solana.nix { inherit pkgs self'; };
              miden = import ./shells/miden.nix { inherit pkgs self'; };
              move = import ./shells/move.nix { inherit pkgs self'; };
              fuel = import ./shells/fuel.nix { inherit pkgs self'; };
              polkavm = import ./shells/polkavm.nix { inherit pkgs self'; };
              cairo = import ./shells/cairo.nix { inherit pkgs self'; };
              circom-recorder = import ./shells/circom-recorder.nix { inherit pkgs self'; };
              leo = import ./shells/leo.nix { inherit pkgs self'; };
              tolk = import ./shells/tolk.nix { inherit pkgs self'; };
              aiken = import ./shells/aiken.nix { inherit pkgs self'; };
              cadence = import ./shells/cadence.nix { inherit pkgs self'; };
            };
        };
    };
}
