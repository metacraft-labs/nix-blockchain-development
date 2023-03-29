_finalNixpkgs: prevNixpkgs: let
  solana-rust-artifacts = prevNixpkgs.callPackage ./packages/solana-rust-artifacts {};

  solana-bpf-tools = prevNixpkgs.callPackage ./packages/solana-bpf-tools {};

  solana-full-sdk = prevNixpkgs.callPackage ./packages/solana-full-sdk {
    inherit solana-rust-artifacts solana-bpf-tools;
  };

  cosmos-theta-testnet = prevNixpkgs.callPackage ./packages/cosmos-theta-testnet {};

  circom = prevNixpkgs.callPackage ./packages/circom/default.nix {};
  circ = prevNixpkgs.callPackage ./packages/circ/default.nix {};

  wasmd = prevNixpkgs.callPackage ./packages/wasmd/default.nix {};

  # erdpy depends on cattrs >= 22.2
  cattrs22-2 = prevNixpkgs.python3Packages.cattrs.overrideAttrs (finalAttrs: previousAttrs: {
    version = "22.2.0";

    src = prevNixpkgs.fetchFromGitHub {
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
          src = prevNixpkgs.fetchFromGitHub {
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
  cryptography36 = prevNixpkgs.callPackage ./packages/python-modules/cryptography36/default.nix {};

  ledgercomm = prevNixpkgs.callPackage ./packages/python-modules/ledgercomm/default.nix {};
  requests-cache = prevNixpkgs.callPackage ./packages/python-modules/requests-cache/default.nix {};

  erdpy = prevNixpkgs.callPackage ./packages/erdpy/default.nix {};
  elrond-go = prevNixpkgs.callPackage ./packages/elrond-go/default.nix {};
  elrond-proxy-go = prevNixpkgs.callPackage ./packages/elrond-proxy-go/default.nix {};

  go-opera = prevNixpkgs.callPackage ./packages/go-opera/default.nix {};

  leap = prevNixpkgs.callPackage ./packages/leap/default.nix {};
  eos-vm = prevNixpkgs.callPackage ./packages/eos-vm/default.nix {};
  cdt = prevNixpkgs.callPackage ./packages/cdt/default.nix {};

  nimbus = prevNixpkgs.callPackage ./packages/nimbus/default.nix {};

  pistache = prevNixpkgs.callPackage ./packages/pistache/default.nix {};
  ffiasm-src = prevNixpkgs.callPackage ./packages/ffiasm/src.nix {};
  zqfield = prevNixpkgs.callPackage ./packages/ffiasm/zqfield.nix {
    inherit ffiasm-src;
  };
  zqfield-default = prevNixpkgs.symlinkJoin {
    name = "zqfield-default";
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
  ffiasm = prevNixpkgs.callPackage ./packages/ffiasm/default.nix {
    inherit ffiasm-src zqfield-default;
  };
  circom_runtime = prevNixpkgs.callPackage ./packages/circom_runtime/default.nix {};
  rapidsnark = prevNixpkgs.callPackage ./packages/rapidsnark/default.nix {
    inherit ffiasm zqfield-default;
  };
  rapidsnark-server = prevNixpkgs.callPackage ./packages/rapidsnark-server/default.nix {
    inherit ffiasm zqfield-default rapidsnark pistache;
  };
in {
  metacraft-labs = rec {
    solana = solana-full-sdk;
    inherit cosmos-theta-testnet;
    inherit circom;

    # Disabled until cvc4 compiles again
    # inherit circ;

    inherit wasmd;
    inherit ledgercomm;
    inherit cryptography36;
    inherit requests-cache;
    inherit erdpy;
    inherit cattrs22-2;

    # Disabled until elrond-go can build with Go >= 1.19
    # inherit elrond-go;
    # inherit elrond-proxy-go;
    inherit go-opera;
    inherit leap;
    inherit eos-vm;
    inherit cdt;

    # Ethereum
    inherit nimbus;
    inherit go-ethereum-capella;

    inherit pistache;
    inherit zqfield-default;
    inherit zqfield;
    inherit ffiasm;
    inherit circom_runtime;
    inherit rapidsnark;
    inherit rapidsnark-server;
  };
}
