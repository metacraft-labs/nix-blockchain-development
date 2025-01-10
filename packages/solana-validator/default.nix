{ pkgs }:
pkgs.solana-validator.overrideAttrs (old: {
  # patches = old.patches ++ [../cargo-build-bpf/patches/main.rs.diff];
})
