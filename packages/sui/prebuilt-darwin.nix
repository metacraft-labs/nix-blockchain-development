# The `sui` CLI on macOS, from MystenLabs' official release archive.
#
# On Linux `default.nix` builds the same tag from source with crane. On macOS
# the prebuilt binary is used instead: MystenLabs publishes `macos-arm64` and
# `macos-x86_64` archives for every mainnet release, built with the `tracing`
# feature the CodeTracer Move recorder depends on (`sui move test --trace`,
# `sui replay --trace`), and the binary links only system frameworks and
# libraries (`/usr/lib/libc++`, `libSystem`, CoreFoundation, Security, ...), so
# it runs unmodified from the store.
#
# Release assets:
# https://github.com/MystenLabs/sui/releases/tag/mainnet-v1.68.1
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = import ./version.nix;

  # Asset suffix and hash per Darwin system. The archive is the one MystenLabs
  # attaches to the `mainnet-v<version>` release.
  assets = {
    aarch64-darwin = {
      arch = "macos-arm64";
      hash = "sha256-p5scOnJtYoWwLkdKv/5fKV2uL2tDvK3uAtEJ79O9o2I=";
    };
    x86_64-darwin = {
      arch = "macos-x86_64";
      hash = "sha256-mug1/fG2Pg5KUWQlhQSU9Tqgb1gLF8HmgC1HNEKIjM4=";
    };
  };

  system = stdenvNoCC.hostPlatform.system;
  asset = assets.${system} or (throw "sui: no prebuilt release archive for ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "sui";
  inherit version;

  src = fetchurl {
    url = "https://github.com/MystenLabs/sui/releases/download/mainnet-v${version}/sui-mainnet-v${version}-${asset.arch}.tgz";
    inherit (asset) hash;
  };

  # The archive unpacks to ~1.2 GB (sui-debug, sui-node, sui-tool, ...). Only
  # the `sui` CLI is wanted, so extract that one member and nothing else.
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    tar -xzf "$src" -C "$out/bin" ./sui
    chmod 0755 "$out/bin/sui"
    runHook postInstall
  '';

  # The release binary carries an ad-hoc linker signature, which arm64 macOS
  # requires before it will run it. Skip the whole fixup phase (strip, shebang
  # patching, ...): rewriting the binary would invalidate that signature.
  dontFixup = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/sui" --version | grep -F "sui ${version}-"
    runHook postInstallCheck
  '';

  meta = {
    description = "Sui CLI (official MystenLabs release binary, built with tracing)";
    homepage = "https://github.com/MystenLabs/sui";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames assets;
    mainProgram = "sui";
  };
}
