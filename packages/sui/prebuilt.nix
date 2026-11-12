# The `sui` CLI from MystenLabs' official release archive, on macOS and on
# aarch64-linux.
#
# On x86_64-linux `default.nix` builds the same tag from source with crane.
# Everywhere else the prebuilt binary is used instead. MystenLabs publishes
# `macos-arm64`, `macos-x86_64` and `ubuntu-aarch64` archives for every
# mainnet release, built with the `tracing` feature the CodeTracer Move
# recorder depends on (`sui move test --trace`, `sui replay --trace`).
#
#  - macOS: the binary links only system frameworks and libraries
#    (`/usr/lib/libc++`, `libSystem`, CoreFoundation, Security, ...), so it
#    runs unmodified from the store.
#  - aarch64-linux: building the whole sui workspace from source needs more
#    disk than an aarch64 CI guest has (the build fails in RocksDB with "No
#    space left on device" after about 40 minutes), and no binary cache holds
#    an aarch64-linux build to substitute instead. The Ubuntu binary is a
#    glibc ELF that needs only libstdc++ and libgcc_s besides glibc;
#    autoPatchelfHook points its interpreter and RUNPATH into the store.
#
# Release assets:
# https://github.com/MystenLabs/sui/releases/tag/mainnet-v1.82.3
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = import ./version.nix;

  # Asset suffix and hash per system. The archive is the one MystenLabs
  # attaches to the `mainnet-v<version>` release.
  assets = {
    aarch64-darwin = {
      arch = "macos-arm64";
      hash = "sha256-hh+IM8XHAIyGrKUOklBDuqjgQzLcvYRsxsMeoO7ha+k=";
    };
    x86_64-darwin = {
      arch = "macos-x86_64";
      hash = "sha256-6hdFYNOmqZ04jwYhkEXRHbfquoKH+bhA3AFq92Y1+sU=";
    };
    aarch64-linux = {
      arch = "ubuntu-aarch64";
      hash = "sha256-GUamLVebHB/ocl1MXCKz117gMSqXzMcm5U3sj5ZrwOY=";
    };
  };

  system = stdenvNoCC.hostPlatform.system;
  asset = assets.${system} or (throw "sui: no prebuilt release archive for ${system}");
in
stdenvNoCC.mkDerivation (
  {
    pname = "sui";
    inherit version;

    src = fetchurl {
      url = "https://github.com/MystenLabs/sui/releases/download/mainnet-v${version}/sui-mainnet-v${version}-${asset.arch}.tgz";
      inherit (asset) hash;
    };

    # The archive unpacks to ~1.2 GB on macOS and ~4.6 GB on Linux (sui-debug,
    # sui-node, sui-tool, ...). Only the `sui` CLI is wanted, so extract that
    # one member and nothing else.
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
  // lib.optionalAttrs stdenvNoCC.hostPlatform.isDarwin {
    # The release binary carries an ad-hoc linker signature, which arm64 macOS
    # requires before it will run it. Skip the whole fixup phase (strip,
    # shebang patching, ...): rewriting the binary would invalidate that
    # signature.
    dontFixup = true;
  }
  // lib.optionalAttrs stdenvNoCC.hostPlatform.isLinux {
    # The fixup phase runs here, so that autoPatchelfHook can rewrite the
    # interpreter (`/lib/ld-linux-aarch64.so.1`) and add a RUNPATH for
    # libstdc++.so.6 and libgcc_s.so.1; glibc comes with the interpreter.
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];

    # MystenLabs ships the binary with its symbol table, which keeps panic
    # backtraces readable. Keep it as published.
    dontStrip = true;
  }
)
