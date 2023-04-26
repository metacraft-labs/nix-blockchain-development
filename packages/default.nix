{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];

  perSystem = {
    self',
    pkgs,
    ...
  }: let
    inherit (pkgs) callPackage lib darwin hostPlatform symlinkJoin fetchFromGitHub;
    inherit (pkgs.lib) optionalAttrs;
    darwinPkgs = {
      inherit (darwin.apple_sdk.frameworks) Foundation;
    };

    # RapidSnark
    ffiasm-src = callPackage ./ffiasm/src.nix {};
    zqfield = callPackage ./ffiasm/zqfield.nix {
      inherit ffiasm-src;
    };
    # Pairing Groups on BN-254, aka alt_bn128
    # Source:
    # https://zips.z.cash/protocol/protocol.pdf (section 5.4.9.1)
    # See also:
    # https://eips.ethereum.org/EIPS/eip-196
    # https://eips.ethereum.org/EIPS/eip-197
    # https://hackmd.io/@aztec-network/ByzgNxBfd
    # https://hackmd.io/@jpw/bn254
    zqfield-bn254 = symlinkJoin {
      name = "zqfield-bn254";
      paths = [
        (zqfield {
          primeNumber = "21888242871839275222246405745257275088696311157297823662689037894645226208583";
          name = "Fq";
        })
        (zqfield
          {
            primeNumber = "21888242871839275222246405745257275088548364400416034343698204186575808495617";
            name = "Fr";
          })
      ];
    };
    ffiasm = callPackage ./ffiasm/default.nix {
      inherit ffiasm-src zqfield-bn254;
    };
    rapidsnark = callPackage ./rapidsnark/default.nix {
      inherit ffiasm zqfield-bn254;
    };

    # Elrond / MultiversX
    # copied from https://github.com/NixOS/nixpkgs/blob/8df7949791250b580220eb266e72e77211bedad9/pkgs/development/python-modules/cryptography/default.nix
    cattrs22-2 = pkgs.python3Packages.cattrs.overrideAttrs (finalAttrs: previousAttrs: {
      version = "22.2.0";

      src = fetchFromGitHub {
        owner = "python-attrs";
        repo = "cattrs";
        rev = "v22.2.0";
        hash = "sha256-Qnrq/mIA/t0mur6IAen4vTmMIhILWS6v5nuf+Via2hA=";
      };

      patches = [];
    });
    cryptography36 = callPackage ./python-modules/cryptography36/default.nix {};

    ledgercomm = callPackage ./python-modules/ledgercomm/default.nix {};
    requests-cache = callPackage ./python-modules/requests-cache/default.nix {inherit cattrs22-2;};

    erdpy = callPackage ./erdpy/default.nix {inherit cryptography36 elrond-go elrond-proxy-go ledgercomm requests-cache;};
    elrond-go = callPackage ./elrond-go/default.nix {};
    elrond-proxy-go = callPackage ./elrond-proxy-go/default.nix {};
  in {
    overlayAttrs = self'.legacyPackages;
    packages = self'.legacyPackages.metacraft-labs;
    legacyPackages.metacraft-labs =
      rec {
        cosmos-theta-testnet = callPackage ./cosmos-theta-testnet {};

        circom = callPackage ./circom/default.nix {};
        circ = callPackage ./circ/default.nix {};

        # https://discourse.nixos.org/t/inconsistent-vendoring-in-buildgomodule-when-overriding-source/9225/6
        go-ethereum-capella = pkgs.go-ethereum.override rec {
          buildGoModule = args:
            pkgs.buildGoModule (args
              // {
                version = "1.11.1";
                src = fetchFromGitHub {
                  owner = "ethereum";
                  repo = "go-ethereum";
                  rev = "v1.11.1";
                  sha256 = "sha256-mYLxwJ0oiKfiz+NZ5bnlY0h2uq5wbeQKrwoCCw23Bg0=";
                };
                subPackages = builtins.filter (x: x != "cmd/puppeth") args.subPackages;
                vendorSha256 = "sha256-6yLkeT5DrAPUohAmobssKkvxgXI8kACxiu17WYbw+n0=";
              });
        };

        go-opera = callPackage ./go-opera/default.nix {};

        circom_runtime = callPackage ./circom_runtime/default.nix {};
      }
      // lib.optionalAttrs hostPlatform.isLinux rec {
        wasmd = callPackage ./wasmd/default.nix {};

        # Solana
        solana-rust-artifacts = callPackage ./solana-rust-artifacts {};

        solana-bpf-tools = callPackage ./solana-bpf-tools {};

        solana = callPackage ./solana-full-sdk {
          inherit solana-rust-artifacts solana-bpf-tools;
        };

        # inherit erdpy elrond-go elrond-proxy-go;

        # EOS / Antelope
        leap = callPackage ./leap/default.nix {};
        eos-vm = callPackage ./eos-vm/default.nix {};
        cdt = callPackage ./cdt/default.nix {};

        # Nimbus
        nimbus = callPackage ./nimbus/default.nix {};
      }
      // lib.optionalAttrs hostPlatform.isx86 rec {
        inherit zqfield-bn254 ffiasm ffiasm-src rapidsnark;
      }
      // lib.optionalAttrs (hostPlatform.isx86 && hostPlatform.isLinux) rec {
        pistache = callPackage ./pistache/default.nix {};
        inherit zqfield-bn254;
        rapidsnark-server = callPackage ./rapidsnark-server/default.nix {
          inherit ffiasm zqfield-bn254 rapidsnark pistache;
        };
      };
  };
}
