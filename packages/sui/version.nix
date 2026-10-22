# The Sui release every platform packages. `default.nix` builds this tag from
# source on Linux and `prebuilt-darwin.nix` installs MystenLabs' release binary
# of the same tag on macOS; both read the version from here so the two cannot
# drift apart.
"1.68.1"
