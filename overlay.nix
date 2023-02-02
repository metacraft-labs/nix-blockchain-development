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
in {
  metacraft-labs = rec {
    solana = solana-full-sdk;
    inherit cosmos-theta-testnet;
    inherit circom;
    inherit circ;
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
  };
}
