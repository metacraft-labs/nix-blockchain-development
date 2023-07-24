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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    crane = {
      url = "github:ipetkov/crane";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    noir = {
      url = "github:noir-lang/noir";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.crane.follows = "crane";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    rust-overlay,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      imports = [./packages];
      perSystem = {
        final,
        self',
        ...
      }: {
        devShells.default = import ./shell.nix {
          pkgs = final;
          inherit self';
        };
      };
    };
}
