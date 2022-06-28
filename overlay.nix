_finalNixpkgs: prevNixpkgs: let
  solana-rust-artifacts = prevNixpkgs.callPackage ./packages/solana-rust-artifacts {};

  solana-bpf-tools = prevNixpkgs.callPackage ./packages/solana-bpf-tools {};

  solana-full-sdk = prevNixpkgs.callPackage ./packages/solana-full-sdk {
    inherit solana-rust-artifacts solana-bpf-tools;
  };

  cosmos-theta-testnet = prevNixpkgs.callPackage ./packages/cosmos-theta-testnet {};

  snowbridge-relayer = prevNixpkgs.callPackage ./packages/snowbridge-relayer {};

  # not working yet
  snowbridge-parachain = prevNixpkgs.callPackage ./packages/snowbridge-parachain {};

  abigen = prevNixpkgs.writeShellScriptBin "abigen" ''
    ${prevNixpkgs.go-ethereum}/bin/abigen $@
  '';
in {
  metacraft-labs = rec {
    solana = solana-full-sdk;
    inherit cosmos-theta-testnet snowbridge-relayer snowbridge-parachain abigen;
  };
}
