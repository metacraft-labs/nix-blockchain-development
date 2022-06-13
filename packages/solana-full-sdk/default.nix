{
  pkgs,
  solana-rust-artifacts,
  solana-bpf-tools,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  name = "solana-${version}";
  version = "1.23.1";

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out
    cp -rf ${solana-rust-artifacts}/* $out
    chmod 0755 -R $out;

    mkdir -p $out/bin/sdk/bpf
    cp -rf ${solana-bpf-tools}/* $out/bin/sdk/bpf/
    chmod 0755 -R $out;
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/solana-labs/solana";
    platforms = platforms.linux;
  };
}
