{ pkgs, ... }:
with pkgs;
mkShell {
  packages = [
    solc
    foundry
    zstd # required by libcodetracer_trace_writer
  ];
}
