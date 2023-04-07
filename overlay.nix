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

  jinja2_fixed = prevNixpkgs.python3Packages.jinja2.override {
    markupsafe = markupsafe-201;
  };
  persistent_fixed = prevNixpkgs.python3Packages.persistent.override {
    sphinx = sphinx_fixed;
  };
  sphinx_fixed = prevNixpkgs.python3Packages.sphinx.override {
    jinja2 = jinja2_fixed;
  };
  factory_boy_fixed = prevNixpkgs.python3Packages.factory_boy.override {
    flask = flask-212;
    flask-sqlalchemy = flask-sqlalchemy-251;
    faker = faker_fixed;
  };
  faker_fixed = prevNixpkgs.python3Packages.faker.override {
    pillow = pillow_fixed;
  };
  pillow_fixed = prevNixpkgs.python3Packages.pillow.override {
    libtiff = libtiff_fixed;
    lcms2 = lcms2_fixed;
    libwebp = libwebp_fixed;
    openjpeg = openjpeg_fixed;
  };
  matplotlib_fixed = prevNixpkgs.python3Packages.matplotlib.override {
    pyparsing = pyparsing-247;
    fonttools = fonttools_fixed;
  };
  pytest_fixed = prevNixpkgs.python3Packages.pytest.override {
    # coverage = coverage-650;
  };
  pytest-cov_fixed = prevNixpkgs.python3Packages.pytest-cov.override {
    coverage = coverage-650;
  };
  virtualenv_fixed = prevNixpkgs.python3Packages.virtualenv.override {
    pytest-timeout = pytest-timeout_fixed;
    flaky = flaky_fixed;
  };
  flaky_fixed = prevNixpkgs.python3Packages.flaky.override {
    nose = nose_fixed;
  };
  nose_fixed = prevNixpkgs.python3Packages.nose.override {
    coverage = coverage-650;
  };
  fonttools_fixed = prevNixpkgs.python3Packages.fonttools.override {
    scipy = scipy_fixed;
  };
  scipy_fixed = prevNixpkgs.python3Packages.scipy.override {
    nose = nose_fixed;
    pythran = pythran_fixed;
  };
  pythran_fixed = prevNixpkgs.python3Packages.pythran.override {
    networkx = networkx_fixed;
  };
  networkx_fixed = prevNixpkgs.python3Packages.networkx.override {
    nose = nose_fixed;
  };
  pytest-timeout_fixed = prevNixpkgs.python3Packages.pytest-timeout.override {
    pytest-cov = pytest-cov_fixed;
  };
  lcms2_fixed = prevNixpkgs.lcms2.override {
    libtiff = libtiff_fixed;
  };
  openjpeg_fixed = prevNixpkgs.openjpeg.override {
    libtiff = libtiff_fixed;
    lcms2 = lcms2_fixed;
  };
  libwebp_fixed = prevNixpkgs.libwebp.override {
    libtiff = libtiff_fixed;
  };
  libtiff_fixed = prevNixpkgs.libtiff.override {
    sphinx = sphinx_fixed;
  };

  flask-212 =
    (prevNixpkgs.python3Packages.flask.override {
      jinja2 = jinja2_fixed;
      werkzeug = werkzeug-212;
    })
    .overridePythonAttrs (old: rec {
      version = "2.1.2";
      pname = "Flask";

      src = prevNixpkgs.python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "sha256-MV3tLd+KYoFWftsnOTAQ/jQGGIuvv+ZaMznVeH2J5Hc=";
      };
    });

  flask-sqlalchemy-251 =
    (prevNixpkgs.python3Packages.flask-sqlalchemy.override {
      flask = flask-212;
    })
    .overridePythonAttrs (old: rec {
      pname = "Flask-SQLAlchemy";
      version = "2.5.1";

      src = prevNixpkgs.python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "sha256-K9pEtD58rLFdTgX/PMH4vJeTbMRkYjQkECv8LDXpWRI=";
      };

      propagatedBuildInputs = old.propagatedBuildInputs ++ [prevNixpkgs.python3Packages.setuptools];
      doCheck = false;
    });

  werkzeug-212 =
    (prevNixpkgs.python3Packages.werkzeug.override {
      markupsafe = markupsafe-201;
      pytest-timeout = pytest-timeout_fixed;
    })
    .overridePythonAttrs (old: rec {
      version = "2.1.2";

      src = prevNixpkgs.python3Packages.fetchPypi {
        pname = "Werkzeug";
        inherit version;
        sha256 = "sha256-HOCOgJPtZ9Y41jh5/Rujc1gX96gN42dNKT9ZhPJftuY=";
      };
    });

  eth-typing-230 = prevNixpkgs.python3Packages.eth-typing.overridePythonAttrs (old: rec {
    version = "2.3.0";

    src = prevNixpkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = "eth-typing";
      rev = "c3210d5e2b867f781c297b5c01ada6c399bc402b"; # commit hash for v2.3.0, as nix has trouble fetching the tag.
      sha256 = "sha256-cuA6vSfCfqgffEhSEuVeKJfxsGLw1mGID9liodE9wcU=";
    };
  });

  eth-utils-110 =
    (prevNixpkgs.python3Packages.eth-utils.override {
      cytoolz = cytoolz-0112;
      toolz = toolz-0112;
      eth-typing = eth-typing-230;
    })
    .overrideAttrs (old: rec {
      version = "1.10.0";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "eth-utils";
        rev = "v${version}";
        sha256 = "sha256-sq3H4HmUFUipqVYleZxWLG1gBsQEoNwcZAXiKckacek=";
      };
    });

  py-ecc-410 =
    (prevNixpkgs.python3Packages.py-ecc.override {
      eth-typing = eth-typing-230;
      eth-utils = eth-utils-110;
    })
    .overridePythonAttrs (old: rec {
      version = "4.1.0";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "py_ecc";
        rev = "v${version}";
        hash = "sha256-qs4dvfdrl6o74FAst6XBAvzjJ7ZCA58s447aCTGIt2Y=";
      };
    });

  eth-keys-034 =
    (prevNixpkgs.python3Packages.eth-keys.override (old: {
      factory_boy = factory_boy_fixed;
      eth-utils = eth-utils-110;
      eth-typing = eth-typing-230;
    }))
    .overridePythonAttrs (old: rec {
      version = "0.3.4";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "eth-keys";
        rev = "v${version}";
        fetchSubmodules = true;
        sha256 = "sha256-P/5v4fk6gtbXju+xyDE9enAsmch+gquzvYUIn4Kvs0Y=";
      };

      pythonImportsCheck = []; # workaround for issue with pythonImportsCheckPhase

      disabledTests =
        old.disabledTests
        ++ [
          "test_coincurve_to_native_invalid_signatures"
          "test_get_abi_strategy_returns_certain_strategies_for_known_type_strings"
        ];
    });

  eth-keyfile-051 =
    (prevNixpkgs.python3Packages.eth-keyfile.override (old: {
      eth-utils = eth-utils-110;
      eth-keys = eth-keys-034;
    }))
    .overridePythonAttrs (old: rec {
      version = "0.5.1";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "eth-keyfile";
        rev = "v${version}";
        fetchSubmodules = true;
        sha256 = "sha256-w3baJFYBn8N5UGjR4Bec8c1UH9O0vbmPpsMfw9KGHCg=";
      };
    });

  eth-abi-211 =
    (prevNixpkgs.python3Packages.eth-abi.override (old: {
      eth-utils = eth-utils-110;
      eth-typing = eth-typing-230;
      parsimonious = parsimonious-081;
    }))
    .overridePythonAttrs (old: rec {
      version = "2.1.1";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "eth-abi";
        rev = "v${version}";
        fetchSubmodules = true;
        sha256 = "sha256-b4rlmyCP1bg4O3gaRNWTPo4ALlidK4gUx0WrsJVHu4g=";
      };
    });

  eth-account-059 =
    (prevNixpkgs.python3Packages.eth-account.override (old: {
      eth-abi = eth-abi-211;
      eth-keyfile = eth-keyfile-051;
      eth-keys = eth-keys-034;
      eth-rlp = eth-rlp-021;
      eth-utils = eth-utils-110;
      hexbytes = hexbytes-023;
      rlp = rlp-201;
    }))
    .overridePythonAttrs (old: rec {
      version = "0.5.9";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "eth-account";
        rev = "v${version}";
        sha256 = "sha256-ouIWVIHkEirF1Ryhp/DwIMtKyXWTcYTsszQjDUGP47M=";
      };
    });

  eth-rlp-021 =
    (prevNixpkgs.python3Packages.eth-rlp.override (old: {
      hexbytes = hexbytes-023;
      rlp = rlp-201;
    }))
    .overridePythonAttrs (old: rec {
      version = "0.2.1";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "eth-rlp";
        rev = "v${version}";
        sha256 = "sha256-BJsFsHyv1DcJ+nqvhDu3+mwYarn9V2rBg9PcpxDeEI8=";
      };

      propagatedBuildInputs = with prevNixpkgs.python3Packages; [
        rlp-201
        hexbytes-023
      ];
    });

  parsimonious-081 = prevNixpkgs.python3Packages.eth-abi.overridePythonAttrs (old: rec {
    pname = "parsimonious";
    version = "0.8.1";

    src = prevNixpkgs.python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-Ot0ziJLVgODLOxo55KG0J/+faHhY/dYQlwU3Qjkan2s=";
    };

    pythonImportsCheck = []; # workaround for issue with pythonImportsCheckPhase

    propagatedBuildInputs = [
      prevNixpkgs.python3Packages.six
      prevNixpkgs.python3Packages.regex
    ];
  });

  typing-extensions-31002 = prevNixpkgs.python3Packages.typing-extensions.overridePythonAttrs (old: rec {
    pname = "typing_extensions";
    version = "3.10.0.2";

    src = prevNixpkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "49f75d16ff11f1cd258e1b988ccff82a3ca5570217d7ad8c5f48205dd99a677e";
    };

    checkInputs = prevNixpkgs.lib.optional (prevNixpkgs.python3Packages.pythonOlder "3.5") prevNixpkgs.python3Packages.typing;
    nativeBuildInputs = with prevNixpkgs.python3Packages; [
      flit-core
      setuptools
    ];
  });

  pyparsing-247 =
    (prevNixpkgs.python3Packages.pyparsing.override (old: {
      jinja2 = jinja2_fixed;
    }))
    .overridePythonAttrs (
      old: rec {
        pname = "pyparsing";
        version = "2.4.7";
        src = prevNixpkgs.fetchFromGitHub {
          owner = "pyparsing";
          repo = pname;
          rev = "pyparsing_${version}";
          sha256 = "sha256-0Dyzw3xiCGhLbXPcL2cq2fZuN1N5StSZ/I86gQHy7pI=";
        };
        pythonImportsCheck = [];
        passthru.tests = {};
        nativeBuildInputs = with prevNixpkgs.python3Packages; [
          setuptools
        ];
      }
    );

  markupsafe-201 = prevNixpkgs.python3Packages.markupsafe.overridePythonAttrs (old: rec {
    pname = "markupsafe";
    version = "2.0.1";

    src = prevNixpkgs.python3Packages.fetchPypi {
      pname = "MarkupSafe";
      inherit version;
      sha256 = "02k2ynmqvvd0z0gakkf8s4idyb606r7zgga41jrkhqmigy06fk2r";
    };
  });

  coverage-650 = prevNixpkgs.python3Packages.coverage.overridePythonAttrs (old: rec {
    pname = "coverage";
    version = "6.5.0";

    src = prevNixpkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-9kLpB1TuPgaw5+UbzjN5WQ52t/drcI4acf8EP4cCXIQ=";
    };
  });

  rlp-201 =
    (prevNixpkgs.python3Packages.rlp.override (old: {
      eth-utils = eth-utils-110;
    }))
    .overridePythonAttrs (old: rec {
      pname = "rlp";
      version = "2.0.1";

      src = prevNixpkgs.python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "665e8312750b3fc5f7002e656d05b9dcb6e93b6063df40d95c49ad90c19d1f0e";
      };
      propagatedBuildInputs = [eth-utils-110];
    });

  toolz-0112 = prevNixpkgs.python3Packages.toolz.overridePythonAttrs (old: rec {
    pname = "toolz";
    version = "0.11.2";

    src = prevNixpkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-azEtXhUThVLxvaik5mww4jbIMbYSsr8ABfih3xCkvDM=";
    };
  });

  cytoolz-0112 =
    (prevNixpkgs.python3Packages.cytoolz.override (old: {
      toolz = toolz-0112;
    }))
    .overridePythonAttrs (old: rec {
      pname = "cytoolz";
      version = "0.11.2";

      src = prevNixpkgs.python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "sha256-6iNmMVOAbt3c5+QVPR1AfWI1fAUSCk6Ehb3fG9WrIrQ=";
      };
    });

  hexbytes-023 =
    (prevNixpkgs.python3Packages.hexbytes.override (old: {
      eth-utils = eth-utils-110;
    }))
    .overridePythonAttrs (old: rec {
      pname = "hexbytes";
      version = "0.2.3";

      src = prevNixpkgs.fetchFromGitHub {
        owner = "ethereum";
        repo = "hexbytes";
        rev = "v${version}";
        sha256 = "sha256-bFk2TMZgwmTCr+jzfWfYd6F2v4a6/+kgk0IHxzoCccI=";
      };
    });

  mythril = prevNixpkgs.callPackage ./packages/python-modules/mythril/default.nix {
    inherit
      eth-typing-230
      eth-utils-110
      py-ecc-410
      eth-keyfile-051
      parsimonious-081
      eth-keys-034
      eth-abi-211
      py-solc-x
      typing-extensions-31002
      pyparsing-247
      markupsafe-201
      coverage-650
      blake2b-py
      py-flags
      rlp-201
      ethereum-input-decoder
      eth-account-059
      pre-commit-2200
      cytoolz-0112
      py-evm
      z3-solver
      persistent_fixed
      matplotlib_fixed
      pytest_fixed
      pytest-cov_fixed
      ;
  };
  py-solc-x = prevNixpkgs.callPackage ./packages/python-modules/py-solc-x/default.nix {};
  blake2b-py = prevNixpkgs.callPackage ./packages/python-modules/blake2b-py/default.nix {};
  py-flags = prevNixpkgs.callPackage ./packages/python-modules/py-flags/default.nix {};
  pre-commit-2200 = prevNixpkgs.callPackage ./packages/pre-commit-2200/default.nix {inherit virtualenv_fixed;};
  ethereum-input-decoder = prevNixpkgs.callPackage ./packages/python-modules/ethereum-input-decoder/default.nix {inherit eth-abi-211 parsimonious-081;};
  py-evm = prevNixpkgs.callPackage ./packages/python-modules/py-evm/default.nix {inherit py-ecc-410 rlp-201 pyethash eth-keys-034 eth-bloom-104 trie;};
  pyethash = prevNixpkgs.callPackage ./packages/python-modules/pyethash/default.nix {};
  trie = prevNixpkgs.callPackage ./packages/python-modules/trie/default.nix {inherit typing-extensions-31002 eth-utils-110 rlp-201 hexbytes-023;};
  eth-bloom-104 = prevNixpkgs.callPackage ./packages/python-modules/eth-bloom-104/default.nix {};
  z3-solver = prevNixpkgs.callPackage ./packages/python-modules/z3-solver/default.nix {inherit jinja2_fixed;};
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

    inherit mythril;
    inherit blake2b-py;
    inherit py-solc-x;
  };
}
