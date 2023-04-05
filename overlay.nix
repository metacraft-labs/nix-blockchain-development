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
  cattrs22-2 = prevNixpkgs.python3Packages.cattrs.overridePythonAttrs (previousAttrs: rec {
    version = "22.2.0";

    src = prevNixpkgs.fetchFromGitHub {
      owner = "python-attrs";
      repo = "cattrs";
      rev = "v${version}";
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
  # Pairing Groups on BN-254, aka alt_bn128
  # Source:
  # https://zips.z.cash/protocol/protocol.pdf (section 5.4.9.1)
  # See also:
  # https://eips.ethereum.org/EIPS/eip-196
  # https://eips.ethereum.org/EIPS/eip-197
  # https://hackmd.io/@aztec-network/ByzgNxBfd
  # https://hackmd.io/@jpw/bn254
  zqfield-bn254 = prevNixpkgs.symlinkJoin {
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
  ffiasm = prevNixpkgs.callPackage ./packages/ffiasm/default.nix {
    inherit ffiasm-src zqfield-bn254;
  };
  circom_runtime = prevNixpkgs.callPackage ./packages/circom_runtime/default.nix {};
  rapidsnark = prevNixpkgs.callPackage ./packages/rapidsnark/default.nix {
    inherit ffiasm zqfield-bn254;
  };
  rapidsnark-server = prevNixpkgs.callPackage ./packages/rapidsnark-server/default.nix {
    inherit ffiasm zqfield-bn254 rapidsnark pistache;
  };

  eth-typing-230 = prevNixpkgs.python3Packages.eth-typing.overridePythonAttrs (old: rec {
    version = "2.3.0";

    src = prevNixpkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = "eth-typing";
      rev = "c3210d5e2b867f781c297b5c01ada6c399bc402b"; # commit hash for v2.3.0, as nix has trouble fetching the tag.
      sha256 = "sha256-cuA6vSfCfqgffEhSEuVeKJfxsGLw1mGID9liodE9wcU=";
    };
  });

  eth-utils-110 = prevNixpkgs.python3Packages.eth-utils.overrideAttrs (old: rec {
    version = "1.10.0";

    src = prevNixpkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = "eth-utils";
      rev = "v${version}";
      sha256 = "sha256-sq3H4HmUFUipqVYleZxWLG1gBsQEoNwcZAXiKckacek=";
    };

    propagatedBuildInputs =
      [prevNixpkgs.python3Packages.eth-hash eth-typing-230]
      ++ prevNixpkgs.lib.optional (!prevNixpkgs.python3Packages.isPyPy) prevNixpkgs.python3Packages.cytoolz
      ++ prevNixpkgs.lib.optional prevNixpkgs.python3Packages.isPyPy prevNixpkgs.python3Packages.toolz;
  });

  py-ecc-410 = prevNixpkgs.python3Packages.py-ecc.overridePythonAttrs (old: rec {
    version = "4.1.0";

    src = prevNixpkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = "py_ecc";
      rev = "v${version}";
      hash = "sha256-qs4dvfdrl6o74FAst6XBAvzjJ7ZCA58s447aCTGIt2Y=";
    };

    propagatedBuildInputs = with prevNixpkgs.python3Packages; [
      cached-property
      eth-typing-230
      eth-utils-110
      mypy-extensions
    ];
  });

  eth-keys-034 = prevNixpkgs.python3Packages.eth-keys.overridePythonAttrs (old: rec {
    version = "0.3.4";

    src = prevNixpkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = "eth-keys";
      rev = "v${version}";
      fetchSubmodules = true;
      sha256 = "sha256-P/5v4fk6gtbXju+xyDE9enAsmch+gquzvYUIn4Kvs0Y=";
    };

    propagatedBuildInputs = [
      eth-utils-110
      eth-typing-230
    ];

    disabledTests = old.disabledTests ++ ["test_coincurve_to_native_invalid_signatures"];
  });

  eth-keyfile-051 = prevNixpkgs.python3Packages.eth-keyfile.overridePythonAttrs (old: rec {
    version = "0.5.1";

    src = prevNixpkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = "eth-keyfile";
      rev = "v${version}";
      fetchSubmodules = true;
      leaveDotGit = true;
      sha256 = "sha256-IG2zO0XnI96UptDmvrBn+wG64oSSRakUBsc8QTsR/NE=";
    };

    propagatedBuildInputs = [
      eth-utils-110
      eth-keys-034
      prevNixpkgs.python3Packages.pycryptodome
      prevNixpkgs.python3Packages.setuptools
    ];
  });
  mythril = prevNixpkgs.callPackage ./packages/python-modules/mythril/default.nix {inherit py-ecc-410 eth-utils-110 eth-keyfile-051 eth-typing-230;};
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
    inherit zqfield-bn254;
    inherit zqfield;
    inherit ffiasm;
    inherit circom_runtime;
    inherit rapidsnark;
    inherit rapidsnark-server;

    inherit eth-keyfile-051 mythril;
  };
}
