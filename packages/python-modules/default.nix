{...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    inherit (pkgs) lib darwin hostPlatform symlinkJoin fetchFromGitHub python3Packages;
    inherit (pkgs.lib) optionalAttrs callPackageWith;
    inherit (self'.legacyPackages) rustPlatformStable rustPlatformNightly;
    callPackage = callPackageWith (pkgs // {rustPlatform = rustPlatformStable;});
    darwinPkgs = {
      inherit (darwin.apple_sdk.frameworks) Foundation;
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
    cryptography36 = callPackage ./cryptography36/default.nix {};

    ledgercomm = callPackage ./ledgercomm/default.nix {};
    requests-cache = callPackage ./requests-cache/default.nix {inherit cattrs22-2;};

    jinja2_fixed = python3Packages.jinja2.override {
      markupsafe = markupsafe-201;
    };
    persistent_fixed = python3Packages.persistent.override {
      sphinx = sphinx_fixed;
    };
    sphinx_fixed = python3Packages.sphinx.override {
      jinja2 = jinja2_fixed;
    };
    factory_boy_fixed = python3Packages.factory_boy.override {
      flask = flask-212;
      flask-sqlalchemy = flask-sqlalchemy-251;
      faker = faker_fixed;
    };
    faker_fixed = python3Packages.faker.override {
      pillow = pillow_fixed;
    };
    pillow_fixed = python3Packages.pillow.override {
      libtiff = libtiff_fixed;
      lcms2 = lcms2_fixed;
      libwebp = libwebp_fixed;
      openjpeg = openjpeg_fixed;
    };
    matplotlib_fixed = python3Packages.matplotlib.override {
      pyparsing = pyparsing-247;
      fonttools = fonttools_fixed;
    };
    pytest-cov_fixed = python3Packages.pytest-cov.override {
      coverage = coverage-650;
    };
    virtualenv_fixed = python3Packages.virtualenv.override {
      pytest-timeout = pytest-timeout_fixed;
    };
    nose_fixed = python3Packages.nose.override {
      coverage = coverage-650;
    };
    fonttools_fixed = python3Packages.fonttools.override {
      scipy = scipy_fixed;
    };
    scipy_fixed = python3Packages.scipy.override {
      nose = nose_fixed;
      pythran = pythran_fixed;
    };
    pythran_fixed = python3Packages.pythran.override {
      networkx = networkx_fixed;
    };
    networkx_fixed = python3Packages.networkx.override {
      nose = nose_fixed;
    };
    pytest-timeout_fixed = python3Packages.pytest-timeout.override {
      pytest-cov = pytest-cov_fixed;
    };
    lcms2_fixed = pkgs.lcms2.override {
      libtiff = libtiff_fixed;
    };
    openjpeg_fixed = pkgs.openjpeg.override {
      libtiff = libtiff_fixed;
      lcms2 = lcms2_fixed;
    };
    libwebp_fixed = pkgs.libwebp.override {
      libtiff = libtiff_fixed;
    };
    libtiff_fixed = pkgs.libtiff.override {
      sphinx = sphinx_fixed;
    };

    flask-212 =
      (python3Packages.flask.override {
        jinja2 = jinja2_fixed;
        werkzeug = werkzeug-212;
      })
      .overridePythonAttrs (old: rec {
        version = "2.1.2";
        pname = "Flask";

        src = python3Packages.fetchPypi {
          inherit pname version;
          sha256 = "sha256-MV3tLd+KYoFWftsnOTAQ/jQGGIuvv+ZaMznVeH2J5Hc=";
        };
      });

    flask-sqlalchemy-251 =
      (python3Packages.flask-sqlalchemy.override {
        flask = flask-212;
      })
      .overridePythonAttrs (old: rec {
        pname = "Flask-SQLAlchemy";
        version = "2.5.1";

        src = python3Packages.fetchPypi {
          inherit pname version;
          sha256 = "sha256-K9pEtD58rLFdTgX/PMH4vJeTbMRkYjQkECv8LDXpWRI=";
        };

        propagatedBuildInputs = old.propagatedBuildInputs ++ [python3Packages.setuptools];
        doCheck = false;
      });

    werkzeug-212 =
      (python3Packages.werkzeug.override {
        markupsafe = markupsafe-201;
        pytest-timeout = pytest-timeout_fixed;
      })
      .overridePythonAttrs (old: rec {
        version = "2.1.2";

        src = python3Packages.fetchPypi {
          pname = "Werkzeug";
          inherit version;
          sha256 = "sha256-HOCOgJPtZ9Y41jh5/Rujc1gX96gN42dNKT9ZhPJftuY=";
        };
      });

    eth-typing-230 = python3Packages.eth-typing.overridePythonAttrs (old: rec {
      version = "2.3.0";

      src = fetchFromGitHub {
        owner = "ethereum";
        repo = "eth-typing";
        rev = "c3210d5e2b867f781c297b5c01ada6c399bc402b"; # commit hash for v2.3.0, as nix has trouble fetching the tag.
        sha256 = "sha256-cuA6vSfCfqgffEhSEuVeKJfxsGLw1mGID9liodE9wcU=";
      };
    });

    eth-utils-110 =
      (python3Packages.eth-utils.override {
        cytoolz = cytoolz-0112;
        toolz = toolz-0112;
        eth-typing = eth-typing-230;
      })
      .overrideAttrs (old: rec {
        version = "1.10.0";

        src = fetchFromGitHub {
          owner = "ethereum";
          repo = "eth-utils";
          rev = "v${version}";
          sha256 = "sha256-sq3H4HmUFUipqVYleZxWLG1gBsQEoNwcZAXiKckacek=";
        };
      });

    py-ecc-410 =
      (python3Packages.py-ecc.override {
        eth-typing = eth-typing-230;
        eth-utils = eth-utils-110;
      })
      .overridePythonAttrs (old: rec {
        version = "4.1.0";

        src = fetchFromGitHub {
          owner = "ethereum";
          repo = "py_ecc";
          rev = "v${version}";
          hash = "sha256-qs4dvfdrl6o74FAst6XBAvzjJ7ZCA58s447aCTGIt2Y=";
        };
      });

    eth-keys-034 =
      (python3Packages.eth-keys.override (old: {
        factory_boy = factory_boy_fixed;
        eth-utils = eth-utils-110;
        eth-typing = eth-typing-230;
      }))
      .overridePythonAttrs (old: rec {
        version = "0.3.4";

        src = fetchFromGitHub {
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
      (python3Packages.eth-keyfile.override (old: {
        eth-utils = eth-utils-110;
        eth-keys = eth-keys-034;
      }))
      .overridePythonAttrs (old: rec {
        version = "0.5.1";

        src = fetchFromGitHub {
          owner = "ethereum";
          repo = "eth-keyfile";
          rev = "v${version}";
          fetchSubmodules = true;
          sha256 = "sha256-w3baJFYBn8N5UGjR4Bec8c1UH9O0vbmPpsMfw9KGHCg=";
        };
      });

    eth-abi-211 =
      (python3Packages.eth-abi.override (old: {
        eth-utils = eth-utils-110;
        eth-typing = eth-typing-230;
        parsimonious = parsimonious-081;
      }))
      .overridePythonAttrs (old: rec {
        version = "2.1.1";

        src = fetchFromGitHub {
          owner = "ethereum";
          repo = "eth-abi";
          rev = "v${version}";
          fetchSubmodules = true;
          sha256 = "sha256-b4rlmyCP1bg4O3gaRNWTPo4ALlidK4gUx0WrsJVHu4g=";
        };
      });

    eth-account-059 =
      (python3Packages.eth-account.override (old: {
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

        src = fetchFromGitHub {
          owner = "ethereum";
          repo = "eth-account";
          rev = "v${version}";
          sha256 = "sha256-ouIWVIHkEirF1Ryhp/DwIMtKyXWTcYTsszQjDUGP47M=";
        };
      });

    eth-rlp-021 =
      (python3Packages.eth-rlp.override (old: {
        hexbytes = hexbytes-023;
        rlp = rlp-201;
      }))
      .overridePythonAttrs (old: rec {
        version = "0.2.1";

        src = fetchFromGitHub {
          owner = "ethereum";
          repo = "eth-rlp";
          rev = "v${version}";
          sha256 = "sha256-BJsFsHyv1DcJ+nqvhDu3+mwYarn9V2rBg9PcpxDeEI8=";
        };

        propagatedBuildInputs = with python3Packages; [
          rlp-201
          hexbytes-023
        ];
      });

    parsimonious-081 = python3Packages.eth-abi.overridePythonAttrs (old: rec {
      pname = "parsimonious";
      version = "0.8.1";

      src = python3Packages.fetchPypi {
        inherit pname version;
        hash = "sha256-Ot0ziJLVgODLOxo55KG0J/+faHhY/dYQlwU3Qjkan2s=";
      };

      pythonImportsCheck = []; # workaround for issue with pythonImportsCheckPhase

      propagatedBuildInputs = [
        python3Packages.six
        python3Packages.regex
      ];
    });

    typing-extensions-31002 = python3Packages.typing-extensions.overridePythonAttrs (old: rec {
      pname = "typing_extensions";
      version = "3.10.0.2";

      src = python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "49f75d16ff11f1cd258e1b988ccff82a3ca5570217d7ad8c5f48205dd99a677e";
      };

      checkInputs = lib.optional (python3Packages.pythonOlder "3.5") python3Packages.typing;
      nativeBuildInputs = with python3Packages; [
        flit-core
        setuptools
      ];
    });

    pyparsing-247 =
      (python3Packages.pyparsing.override (old: {
        jinja2 = jinja2_fixed;
      }))
      .overridePythonAttrs (
        old: rec {
          pname = "pyparsing";
          version = "2.4.7";
          src = fetchFromGitHub {
            owner = "pyparsing";
            repo = pname;
            rev = "pyparsing_${version}";
            sha256 = "sha256-0Dyzw3xiCGhLbXPcL2cq2fZuN1N5StSZ/I86gQHy7pI=";
          };
          pythonImportsCheck = [];
          passthru.tests = {};
          nativeBuildInputs = with python3Packages; [
            setuptools
          ];
        }
      );

    markupsafe-201 = python3Packages.markupsafe.overridePythonAttrs (old: rec {
      pname = "markupsafe";
      version = "2.0.1";

      src = python3Packages.fetchPypi {
        pname = "MarkupSafe";
        inherit version;
        sha256 = "02k2ynmqvvd0z0gakkf8s4idyb606r7zgga41jrkhqmigy06fk2r";
      };
    });

    coverage-650 = python3Packages.coverage.overridePythonAttrs (old: rec {
      pname = "coverage";
      version = "6.5.0";

      src = python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "sha256-9kLpB1TuPgaw5+UbzjN5WQ52t/drcI4acf8EP4cCXIQ=";
      };
    });

    rlp-201 =
      (python3Packages.rlp.override (old: {
        eth-utils = eth-utils-110;
      }))
      .overridePythonAttrs (old: rec {
        pname = "rlp";
        version = "2.0.1";

        src = python3Packages.fetchPypi {
          inherit pname version;
          sha256 = "665e8312750b3fc5f7002e656d05b9dcb6e93b6063df40d95c49ad90c19d1f0e";
        };
        propagatedBuildInputs = [eth-utils-110];
      });

    toolz-0112 = python3Packages.toolz.overridePythonAttrs (old: rec {
      pname = "toolz";
      version = "0.11.2";

      src = python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "sha256-azEtXhUThVLxvaik5mww4jbIMbYSsr8ABfih3xCkvDM=";
      };
    });

    cytoolz-0112 =
      (python3Packages.cytoolz.override (old: {
        toolz = toolz-0112;
      }))
      .overridePythonAttrs (old: rec {
        pname = "cytoolz";
        version = "0.11.2";

        src = python3Packages.fetchPypi {
          inherit pname version;
          sha256 = "sha256-6iNmMVOAbt3c5+QVPR1AfWI1fAUSCk6Ehb3fG9WrIrQ=";
        };
      });

    hexbytes-023 =
      (python3Packages.hexbytes.override (old: {
        eth-utils = eth-utils-110;
      }))
      .overridePythonAttrs (old: rec {
        pname = "hexbytes";
        version = "0.2.3";

        src = fetchFromGitHub {
          owner = "ethereum";
          repo = "hexbytes";
          rev = "v${version}";
          sha256 = "sha256-bFk2TMZgwmTCr+jzfWfYd6F2v4a6/+kgk0IHxzoCccI=";
        };
      });

    mythril = callPackage ./mythril/default.nix {
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
        pytest-cov_fixed
        ;
    };
    py-solc-x = callPackage ./py-solc-x/default.nix {};
    blake2b-py = callPackage ./blake2b-py/default.nix {rustPlatform = rustPlatformNightly;};
    py-flags = callPackage ./py-flags/default.nix {};
    pre-commit-2200 = callPackage ./pre-commit-2200/default.nix {inherit virtualenv_fixed;};
    ethereum-input-decoder = callPackage ./ethereum-input-decoder/default.nix {inherit eth-abi-211 parsimonious-081;};
    py-evm = callPackage ./py-evm/default.nix {inherit py-ecc-410 rlp-201 pyethash eth-keys-034 eth-bloom-104 trie;};
    pyethash = callPackage ./pyethash/default.nix {};
    trie = callPackage ./trie/default.nix {inherit typing-extensions-31002 eth-utils-110 rlp-201 hexbytes-023;};
    eth-bloom-104 = callPackage ./eth-bloom-104/default.nix {};
    z3-solver = callPackage ./z3-solver/default.nix {inherit jinja2_fixed;};
  in {
    legacyPackages.python-modules = {
      inherit cryptography36 ledgercomm requests-cache cattrs22-2;

      inherit mythril;
      inherit blake2b-py;
      inherit py-solc-x;
    };
  };
}
