{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  autoPatchelfHook,
}:
buildGoModule rec {
  pname = "wasmd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "CosmWasm";
    repo = "wasmd";
    rev = "d63bea442bedf5b3055f3821472c7e6cafc3d813";
    sha256 = "sha256-hN7XJDoZ8El2tvwJnW67abhwg37e1ckFyreytN2AwZ0=";
  };
  proxyVendor = true;

  subPackages = ["cmd/wasmd"];

  buildInputs = [autoPatchelfHook];

  postBuild = ''
    mkdir -p "$out/lib"
    cp "$GOPATH/pkg/mod/github.com/!cosm!wasm/wasmvm@v1.0.0/api/libwasmvm.x86_64.so" "$out/lib"
  '';

  postInstall = ''
    addAutoPatchelfSearchPath "$out/lib"
    autoPatchelf -- "$out/bin"
  '';

  vendorSha256 = "sha256-4vW1+vGOwbaE6fVXtHjKMheX9UpiY7WVh7QCC57QQUM=";
  doCheck = false;
  meta = with lib; {
    description = "Basic cosmos-sdk app with web assembly smart contracts";
    homepage = "https://github.com/CosmWasm/wasmd";
    license = licenses.asl20;
    maintainers = with maintainers; [];
  };
}
