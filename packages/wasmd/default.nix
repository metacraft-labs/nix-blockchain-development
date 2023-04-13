{
  lib,
  stdenv,
  fetchFromGitHub,
  go_1_19,
  autoPatchelfHook,
  callPackage,
}: let
  system = stdenv.targetPlatform.system;
  libwasmvm_files = {
    x86_64-linux = "libwasmvm.x86_64.so";
    aarch64-linux = "libwasmvm.aarch64.so";

    # WasmVM has a universal library for both x86_64 and aarch64:
    # https://github.com/CosmWasm/wasmvm/pull/294
    x86_64-darwin = "libwasmvm.dylib";
    aarch64-darwin = "libwasmvm.dylib";
  };
  so_name = libwasmvm_files.${system} or (throw "Unsupported system: ${system}");
  buildGoModule = callPackage ./module.nix {go = go_1_19;};
in
  buildGoModule rec {
    pname = "wasmd";
    version = "0.31.0";

    src = fetchFromGitHub {
      owner = "CosmWasm";
      repo = "wasmd";
      rev = "v${version}";
      hash = "sha256-lxx1rKvgzvWKeGnUG4Ij7K6tfL7u3cIaf6/CYRvkqLg=";
    };

    proxyVendor = true;
    vendorSha256 = "sha256-Mv4Y7bsmBBnRkOxgosQDXD8jLXlS+rbz7GPCXjj5cto=";

    subPackages = ["cmd/wasmd"];

    nativeBuildInputs = lib.optionals stdenv.isLinux [autoPatchelfHook];

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
      maintainers = with maintainers; [];
    };
  }
