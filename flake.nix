{
  description = "nix-blockchain-development";

  nixConfig = {
    extra-substituters = [
      "https://mcl-blockchain-packages.cachix.org"
      "https://nix-blockchain-development.cachix.org"
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "mcl-blockchain-packages.cachix.org-1:qoEiUyBgNXmgJTThjbjO//XA9/6tCmx/OohHHt9hWVY="
      "nix-blockchain-development.cachix.org-1:Ekei3RuW3Se+P/UIo6Q/oAgor/fVhFuuuX5jR8K/cdg="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  inputs = {
    nixos-modules.url = "github:metacraft-labs/nixos-modules";

    nixpkgs.follows = "nixos-modules/nixpkgs";
    flake-parts.follows = "nixos-modules/flake-parts";
    flake-utils.follows = "nixos-modules/flake-utils";
    flake-compat.follows = "nixos-modules/flake-compat";
    nix2container.follows = "nixos-modules/nix2container";
    crane.follows = "nixos-modules/crane";
    fenix.follows = "nixos-modules/fenix";
    ethereum_nix.follows = "nixos-modules/ethereum-nix";
    treefmt-nix.follows = "nixos-modules/treefmt-nix";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      imports = [./packages];
      perSystem = {
        final,
        self',
        ...
      }: {
        devShells.default = import ./shells/all.nix {
          pkgs = final;
          inherit self';
        };
        devShells.ci = import ./shells/ci.nix {pkgs = final;};
      };
    };
}
