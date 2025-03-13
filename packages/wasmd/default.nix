{
  lib,
  stdenv,
  fetchFromGitHub,
  go_1_23,
  autoPatchelfHook,
  pkgs,
  gccForLibs,
}:
let
  inherit (stdenv.targetPlatform) system;
  libwasmvm_files = {
    x86_64-linux = "libwasmvm.x86_64.so";
    aarch64-linux = "libwasmvm.aarch64.so";

    # WasmVM has a universal library for both x86_64 and aarch64:
    # https://github.com/CosmWasm/wasmvm/pull/294
    x86_64-darwin = "libwasmvm.dylib";
    aarch64-darwin = "libwasmvm.dylib";
  };
  so_name = libwasmvm_files.${system} or (throw "Unsupported system: ${system}");
  buildGoModule = pkgs.buildGoModule.override { go = go_1_23; };
in
buildGoModule rec {
  pname = "wasmd";
  version = "0.55.0";

  src = fetchFromGitHub {
    owner = "CosmWasm";
    repo = "wasmd";
    rev = "v${version}";
    hash = "sha256-eqZ0flKczjZDazaA2CHsPwZofMiIXLLRewSz4HLQFLo=";
  };

  proxyVendor = true;
  vendorHash = "sha256-Vj0as1zfs/qiDzD98aMW7jk11QvEzRgguyDK/+SGF3s=";

  subPackages = [ "cmd/wasmd" ];

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.isLinux [ gccForLibs.libgcc ];

  postBuild = ''
    mkdir -p "$out/lib"
    cp "$GOPATH/pkg/mod/github.com/!cosm!wasm/wasmvm@v1.2.1/internal/api/${so_name}" "$out/lib"
  '';

  postInstall = ''
    addAutoPatchelfSearchPath "$out/lib"
    # TODO: autoPatchElf is Linux-specific. We need a cross-platform solution
    autoPatchelf -- "$out/bin"
  '';

  doCheck = false;
  meta = with lib; {
    description = "Basic cosmos-sdk app with web assembly smart contracts";
    homepage = "https://github.com/CosmWasm/wasmd";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
