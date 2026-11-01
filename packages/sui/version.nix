# The Sui release every platform packages. `default.nix` builds this tag from
# source on Linux and `prebuilt-darwin.nix` installs MystenLabs' release binary
# of the same tag on macOS; both read the version from here so the two cannot
# drift apart.
#
# The CodeTracer Move recorder traces mainnet with `sui replay --trace`, and a
# `sui` refuses to replay a transaction executed under a protocol version newer
# than the newest it knows. Mainnet raises its protocol version every few
# weeks, so this pin has to follow it. `tests/test_sui_replays_current_mainnet.sh`
# (`just test-sui-mainnet-replay`) replays a current mainnet transaction and
# fails once the pin has fallen behind. To bump, set the newest `mainnet-v*`
# release (https://github.com/MystenLabs/sui/releases) here and update, for
# that tag:
#   - default.nix `src` hash:
#       nix-prefetch-url --unpack https://github.com/MystenLabs/sui/archive/mainnet-v<version>.tar.gz
#   - default.nix `rust-toolchain` sha256, the hash of the channel manifest
#     named by the tag's rust-toolchain.toml:
#       nix-prefetch-url https://static.rust-lang.org/dist/channel-rust-<channel>.toml
#   - prebuilt-darwin.nix hash of each macOS release archive:
#       nix-prefetch-url https://github.com/MystenLabs/sui/releases/download/mainnet-v<version>/sui-mainnet-v<version>-<arch>.tgz
# (convert each printed hash with `nix hash convert --hash-algo sha256`).
"1.82.3"
