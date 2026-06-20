{
  description = "nix-blockchain-development";

  nixConfig = {
    extra-substituters = [
      "https://cache.metacraft-labs.com/metacraft-public"
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "metacraft-public:UtS6PK+p0uZaJK3i/jD2DQOjTpddhQUQmNQDQih5N4Q="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  inputs = {
    nixos-modules.url = "github:metacraft-labs/nixos-modules";

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
          devShells.default = import ./shells/all.nix {
            inherit pkgs self';
          };
          devShells.ci = import ./shells/ci.nix {
            inherit pkgs config;
          };
          devShells.nexus = import ./shells/nexus.nix { inherit pkgs config; };
          devShells.jolt = import ./shells/jolt.nix { inherit pkgs config; };
          devShells.zkm = import ./shells/zkm.nix { inherit pkgs config; };
          devShells.zkwasm = import ./shells/zkwasm.nix { inherit pkgs config; };
          devShells.sp1 = import ./shells/sp1.nix { inherit pkgs config; };
          devShells.risc0 = import ./shells/risc0.nix { inherit pkgs config; };
          devShells.evm = import ./shells/evm.nix { inherit pkgs; };
          devShells.solana = import ./shells/solana.nix { inherit pkgs self'; };
          devShells.miden = import ./shells/miden.nix { inherit pkgs self'; };
          devShells.move = import ./shells/move.nix { inherit pkgs self'; };
          devShells.fuel = import ./shells/fuel.nix { inherit pkgs self'; };
          devShells.polkavm = import ./shells/polkavm.nix { inherit pkgs self'; };
          devShells.cairo = import ./shells/cairo.nix { inherit pkgs self'; };
          devShells.circom-recorder = import ./shells/circom-recorder.nix { inherit pkgs self'; };
          devShells.leo = import ./shells/leo.nix { inherit pkgs self'; };
          devShells.tolk = import ./shells/tolk.nix { inherit pkgs self'; };
          devShells.aiken = import ./shells/aiken.nix { inherit pkgs self'; };
          devShells.cadence = import ./shells/cadence.nix { inherit pkgs self'; };
        };
    };
}
