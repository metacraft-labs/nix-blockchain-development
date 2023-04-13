_finalNixpkgs: prevNixpkgs: let
  inherit (prevNixpkgs) callPackage symlinkJoin fetchFromGitHub;

  solana-rust-artifacts = callPackage ./packages/solana-rust-artifacts {};

  solana-bpf-tools = callPackage ./packages/solana-bpf-tools {};

  solana-full-sdk = callPackage ./packages/solana-full-sdk {
    inherit solana-rust-artifacts solana-bpf-tools;
  };

  cosmos-theta-testnet = callPackage ./packages/cosmos-theta-testnet {};

  circom = callPackage ./packages/circom/default.nix {};
  circ = callPackage ./packages/circ/default.nix {};

  wasmd = callPackage ./packages/wasmd/default.nix {};

  # erdpy depends on cattrs >= 22.2
  cattrs22-2 = prevNixpkgs.python3Packages.cattrs.overrideAttrs (finalAttrs: previousAttrs: {
    version = "22.2.0";

    src = fetchFromGitHub {
      owner = "python-attrs";
      repo = "cattrs";
      rev = "v22.2.0";
      hash = "sha256-Qnrq/mIA/t0mur6IAen4vTmMIhILWS6v5nuf+Via2hA=";
    };

    patches = [];
  });

  # https://discourse.nixos.org/t/inconsistent-vendoring-in-buildgomodule-when-overriding-source/9225/6
  go-ethereum-capella = prevNixpkgs.go-ethereum.override rec {
    buildGoModule = args:
      prevNixpkgs.buildGoModule (args
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

  # copied from https://github.com/NixOS/nixpkgs/blob/8df7949791250b580220eb266e72e77211bedad9/pkgs/development/python-modules/cryptography/default.nix
  cryptography36 = callPackage ./packages/python-modules/cryptography36/default.nix {};

  ledgercomm = callPackage ./packages/python-modules/ledgercomm/default.nix {};
  requests-cache = callPackage ./packages/python-modules/requests-cache/default.nix {};

  erdpy = callPackage ./packages/erdpy/default.nix {};
  elrond-go = callPackage ./packages/elrond-go/default.nix {};
  elrond-proxy-go = callPackage ./packages/elrond-proxy-go/default.nix {};

  go-opera = callPackage ./packages/go-opera/default.nix {};

  leap = callPackage ./packages/leap/default.nix {};
  eos-vm = callPackage ./packages/eos-vm/default.nix {};
  cdt = callPackage ./packages/cdt/default.nix {};

  nimbus = callPackage ./packages/nimbus/default.nix {};

  pistache = callPackage ./packages/pistache/default.nix {};
  ffiasm-src = callPackage ./packages/ffiasm/src.nix {};
  zqfield = callPackage ./packages/ffiasm/zqfield.nix {
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
  ffiasm = callPackage ./packages/ffiasm/default.nix {
    inherit ffiasm-src zqfield-bn254;
  };
  circom_runtime = callPackage ./packages/circom_runtime/default.nix {};
  rapidsnark = callPackage ./packages/rapidsnark/default.nix {
    inherit ffiasm zqfield-bn254;
  };
  rapidsnark-server = callPackage ./packages/rapidsnark-server/default.nix {
    inherit ffiasm zqfield-bn254 rapidsnark pistache;
  };
in {
  metacraft-labs = rec {
    solana = solana-full-sdk;
    inherit cosmos-theta-testnet;
    inherit circom;

    # Disabled until cvc4 compiles again
    # inherit circ;

    inherit wasmd;

    # ElrondGo:
    inherit ledgercomm;
    inherit cryptography36;
    inherit cattrs22-2;
    inherit requests-cache;
    # Disabled until elrond-go can build with Go >= 1.19
    # Issue #65
    # inherit elrond-go;
    # inherit elrond-proxy-go;
    # inherit erdpy;

    inherit go-opera;
    inherit leap;
    inherit eos-vm;
    inherit cdt;

    # Ethereum
    inherit nimbus;
    inherit go-ethereum-capella;

    inherit pistache;
    inherit zqfield-bn254;
    inherit zqfield;
    inherit ffiasm;
    inherit circom_runtime;
    inherit rapidsnark;
    inherit rapidsnark-server;
  };
}
