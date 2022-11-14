{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  autoPatchelfHook,
}:
let
  wasmvmLib = if stdenv.isLinux then "libwasmvm.x86_64.so"
              else if stdenv.isDarwin then "libwasmvm.dylib"
              else throw "platform not supported";
in
buildGoModule rec {
  pname = "wasmd";
  version = "0.14.99";

  src = fetchFromGitHub {
    owner = "CosmWasm";
    repo = "wasmd";
    rev = "d63bea442bedf5b3055f3821472c7e6cafc3d813";
    sha256 = "sha256-hN7XJDoZ8El2tvwJnW67abhwg37e1ckFyreytN2AwZ0=";
  };
  proxyVendor = true;

  subPackages = ["cmd/wasmd"];

  buildInputs = [] ++ lib.optional stdenv.isLinux [autoPatchelfHook];

  postBuild = ''
    mkdir -p "$out/lib"
    # TODO: The correct binary below should depend on the current OS and CPU
    cp "$GOPATH/pkg/mod/github.com/!cosm!wasm/wasmvm@v1.0.0/api/${wasmvmLib}" "$out/lib"
  '';

  postInstall = if stdenv.isLinux then ''
    addAutoPatchelfSearchPath "$out/lib"
    # TODO: autoPatchElf is Linux-specific. We need a cross-platform solution
    autoPatchelf -- "$out/bin"
  '' else
  # TODO
  # The package is still not working because we are missing the equivalent
  # of autopatchelf for macOS. The "libwasmvm.dylib" is currently distributed
  # as a pre-built binary by the wasmd team (it's stored in git). This leads
  # to the final wasmd binary having a `rpath` which cannot be satisfied at
  # run-time with Nix.
  "";

  vendorSha256 = if stdenv.isLinux then
    "sha256-4vW1+vGOwbaE6fVXtHjKMheX9UpiY7WVh7QCC57QQUM="
  else if stdenv.isDarwin then
    "sha256-vACKDwUP52iSjb0DC+dIuNrOeBMLnKBDYsNpQrq3IqI="
  else "";

  doCheck = false;
  meta = with lib; {
    description = "Basic cosmos-sdk app with web assembly smart contracts";
    homepage = "https://github.com/CosmWasm/wasmd";
    license = licenses.asl20;
    maintainers = with maintainers; [];
  };
}
