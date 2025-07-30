# nix-blockchain-development

A Nix flake offering blockchain development tools

## Packages

This repo is provided as a Nix Flake. The packages defined here can be consumed
via one of the flake output categories:

- `overlays.default` (which you can e.g. apply on top of Nixpkgs)
  - All packages are placed inside the `metacraft-labs` namespace
  - For example: `metacraft-labs.solana`
- `packages.${arch}.${pkg}` - suitable for use with `nix shell`

### Blockchain Node Software

| package name                             | description                                                                                                             | supported platforms                         |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| [avalanche-cli]([avalanche-url])         | Helps developers develop and test subnets                                                                               | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [cardano]([cardano-url])                 | HTTP server & command-line for managing UTxOs and HD wallets in Cardano                                                 | x86_64-linux, x86_64-darwin                 |
| [cardano-graphql]([cardano-graphql-url]) | GraphQL API for Cardano                                                                                                 | x86_64-linux, x86_64-darwin                 |
| [cosmos-theta-testnet][cosmos-url]       | Cosmos Testnets                                                                                                         | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [gaiad]([gaiad-url])                     | Cosmos Hub is the first of many interconnected blockchains powered by the interchain stack: CometBFT, CosmosSDK and IBC | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [wasmd]([wasmd-url])                     | Basic cosmos-sdk app with web assembly smart contracts                                                                  | x86_64-linux                                |
| [cdt]([cdt-url])                         | A suite of tools to facilitate C/C++ development of contracts for Antelope blockchains                                  | x86_64-linux                                |
| [eos-vm]([eos-vm-url])                   | A Low-Latency, High Performance and Extensible WebAssembly Engine                                                       | x86_64-linux                                |
| [leap]([leap-url])                       | C++ implementation of the Antelope protocol                                                                             | x86_64-linux                                |
| [go-opera]([go-opera-url])               | Opera blockchain protocol secured by the Lachesis consensus algorithm                                                   | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [polkadot]([polkadot-url])               | Polkadot Node Implementation                                                                                            | x86_64-linux, x86_64-darwin, aarch64-darwin |
| polkadot-fast                            | Polkadot Node Implementation with [fast-runtime][polkadot-fast-url] enabled                                             | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [nimbus]([nimbus-url])                   | Lightweight Ethereum consensus layer client | x86_64-linux, aarch64-linux, armv7a-linux, x86_64-darwin, aarch64-darwin, x86_64-windows |
| [solana-validator]([solana-validator-url]) | Solana validator node              | x86_64-linux |

### ZK Circuit-related Software

| package name                           | description                                                                | supported platforms                         |
| -------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------- |
| [circom]([circom-url])                 | zkSnark circuit compiler                                                   | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [circom_runtime]([circom_runtime-url]) | The code needed to calculate the witness by a circuit compiled with circom | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [ffiasm]([ffiasm-url])                 | A script that generates a Finite field Library in Intel64 and ARM Assembly | x86_64-linux, x86_64-darwin                 |
| [ffiasm-src]([ffiasm-src-url])         | Intel assembly finite field library generator                              | x86_64-linux, x86_64-darwin                 |
| [rapidsnark]([rapidsnark-url])         | zkSnark proof generation written in C++ and intel assembly                 | x86_64-linux, x86_64-darwin                 |
| rapidsnark-gpu                        | GPU-accelerated prover for Rapidsnark                                   | x86_64-linux, x86_64-darwin |
| rapidsnark-server                      |                                                                            | x86_64-linux                                |
| zqfield-bn254                          |                                                                            | x86_64-linux, x86_64-darwin                 |

### ZK Virtual Machines

#### Virtual Machines

| package name           | description                                                                                                        | supported platforms |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------- |
| [jolt]([jolt-url])     | RISC-V-based zkVM with simplicity, speed and extensibility in mind                                                 | x86_64-linux        |
| [nexus]([nexus-url])   | A modular, extensible and highly-parallelized zkVM                                                                 | x86_64-linux        |
| [risc0]([risc0-url])   | Zero-knowledge verifiable general computing platform based on zk-STARKS and RISC-V                                 | x86_64-linux        |
| [sp1]([sp1-url])       | The fastest, most-feature complete zkVM for developers                                                             | x86_64-linux        |
| [zkm]([zkm-url])       | General verifiable computing infrastructure, empowering Ethereum as the Global Settlement Layer                    | x86_64-linux        |
| [zkwasm]([zkwasm-url]) | ZKWASM serves as a trustless layer between rich applilcations running on WASM runtime and smart contracts on chain | x86_64-linux        |

#### Virtual Machine Rust forks

| package name                             | description                                               | supported platforms |
| ---------------------------------------- | --------------------------------------------------------- | ------------------- |
| [jolt-guest-rust]([jolt-guest-rust-url]) | Rust with the riscv32im-jolt-zkvm-elf compilation target  | x86_64-linux        |
| [risc0-rust]([risc0-rust-url])           | Rust with the riscv32im-risc0-zkvm-elf compilation target | x86_64-linux        |

### General Dev Tools

| package name                 | description                                                                                                               | supported platforms                         |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| [emscripten][emscripten-url] | An LLVM-to-WebAssembly Compiler                                                                                           | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [kurtosis]([kurtosis-url])   | A platform for packaging and launching ephemeral backend stacks with a focus on approachability for the average developer | x86_64-linux                                |
| cargo-build-bpf               | Solana SDK helper for building BPF programs | x86_64-linux |

### Libraries

#### Cryptography-related

| package name           | description                                                                    | supported platforms                         |
| ---------------------- | ------------------------------------------------------------------------------ | ------------------------------------------- |
| [blst]([blst-url])     | Multilingual BLS12-381 signature library                                       | x86_64-linux, x86_64-darwin, aarch64-darwin |
| [py-ecc]([py-ecc-url]) | Python implementation of ECC pairing and bn_128 and bls12_381 curve operations | x86_64-linux                                |

#### General-purpose

| package name               | description                                    | supported platforms |
| -------------------------- | ---------------------------------------------- | ------------------- |
| [pistache]([pistache-url]) | A high-performance REST toolkit written in C++ | x86_64-linux        |

[cosmos-url]: https://github.com/hyphacoop/testnets/blob/master/local/previous-local-testnets/v7-theta/priv_validator_key.json
[emscripten-url]: https://github.com/emscripten-core/emscripten
[avalanche-url]: https://github.com/ava-labs/avalanche-cli
[blst-url]: https://github.com/supranational/blst
[cardano-url]: https://github.com/woofpool/cardano-private-testnet-setup
[cdt-url]: https://github.com/AntelopeIO/cdt
[circom-url]: https://github.com/iden3/circom
[circom_runtime-url]: https://github.com/iden3/circom_runtime
[eos-vm-url]: https://github.com/AntelopeIO/eos-vm
[ffiasm-url]: https://github.com/iden3/ffiasm
[ffiasm-src-url]: https://github.com/iden3/ffiasm-old
[gaiad-url]: https://github.com/cosmos/gaia
[go-opera-url]: https://github.com/Fantom-foundation/go-opera
[cardano-graphql-url]: https://github.com/cardano-foundation/cardano-graphql
[jolt-url]: https://github.com/a16z/jolt
[nexus-url]: https://github.com/nexus-xyz/nexus-zkvm
[risc0-url]: https://github.com/risc0/risc0
[sp1-url]: https://github.com/succinctlabs/sp1
[zkm-url]: https://github.com/zkMIPS/zkm
[zkwasm-url]: https://github.com/DelphinusLab/zkWasm
[jolt-guest-rust]: https://github.com/a16z/rust
[risc0-rust]: https://github.com/risc0/rust
[kurtosis-url]: https://github.com/kurtosis-tech/kurtosis
[pistache-url]: https://github.com/pistacheio/pistache
[polkadot-url]: https://github.com/paritytech/polkadot
[py-ecc-url]: https://github.com/ethereum/py_ecc
[rapidsnark-url]: https://github.com/iden3/rapidsnark-old
[wasmd-url]: https://github.com/CosmWasm/wasmd
[polkadot-fast-url]: https://github.com/paritytech/polkadot/blob/52209dcfe546ff39cc031b92d64e787e7e8264d4/Cargo.toml#L228
[nimbus-url]: https://github.com/status-im/nimbus-eth2
[solana-validator-url]: https://github.com/solana-labs/solana
[rapidsnark-gpu-url]: https://github.com/Orbiter-Finance/rapidsnark
[cargo-build-bpf-url]: https://github.com/solana-labs/solana/tree/master/sdk/cargo-build-bpf

## Usage examples

### Imperative (ad hoc) with `nix shell`

```sh
# Replace solana with the package you want to use:
nix shell github:metacraft-labs/nix-blockchain-development#solana
```

### Declarative with Nix Flakes dev shell

- `flake.nix`:

  ```nix
  {
    # <after>:
    # Opt into `nix-blockchain-development`'s substituter (binary cache).
    # `nixConfig` settings are not transitive so every user of a flake with a
    # custom binary cache must manually include its `nixConfig` settings for
    # substituters and trusted public keys:
    nixConfig = {
      extra-substituters = "https://nix-blockchain-development.cachix.org";
      extra-trusted-public-keys = "nix-blockchain-development.cachix.org-1:Ekei3RuW3Se+P/UIo6Q/oAgor/fVhFuuuX5jR8K/cdg=";
    };

    inputs = {
      # <before>:
      # nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
      # flake-utils.url = github:numtide/flake-utils;

      # <after>:
      # To ensure all packages from mcl-blockchain will be fetched from its
      # binary cache we need to ensure that we use exact same commit hash of the
      # inputs below. If we didn't, we may either:
      # * end up with multiple copies of the same package from nixpkgs
      # * be unable to use the binary cache, since the packages there where
      #   using different versions of their dependencies from nixpkgs
      mcl-blockchain.url = "github:metacraft-labs/nix-blockchain-development";
      nixpkgs.follows = "mcl-blockchain/nixpkgs";
      flake-utils.follows = "mcl-blockchain/flake-utils";
    };

    outputs = {
      self,
      nixpkgs,
      flake-utils,
      mcl-blockchain, # <after>
    }:
      flake-utils.lib.simpleFlake {
        inherit self nixpkgs;
        name = "solana-hello-world";
        shell = ./shell.nix;
        preOverlays = [mcl-blockchain.overlays.default]; # <after>
      };
  }
  ```

- `shell.nix`:

  ```nix
  {pkgs}:
  with pkgs;
    mkShell {
      packages = [
        metacraft-labs.polkadot # <after>
      ];
    }
  ```
