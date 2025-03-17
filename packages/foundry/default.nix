{
  unstable-pkgs,
  ...
}:
with unstable-pkgs;
rustPlatform.buildRustPackage rec {
  pname = "foundry";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "foundry-rs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-YTsneUj5OPw7EyKZMFLJJeAtZoD0je1DdmfMjVju4L8=";
  };

  solc-bin-json = fetchurl {
    url = "https://raw.githubusercontent.com/ethereum/solc-bin/f5f39aa9f399dbd24e2dcbccb9e277c573a49d1b/linux-amd64/list.json";
    hash = "sha256-uiVRa6ewZDd1W62Vp5GGruJDO+fH8G8abVkz3XZZ/u8=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  doCheck = false;

  SVM_RELEASES_LIST_JSON = "${solc-bin-json}";

  meta = {
    description = "Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.";
    homepage = "https://github.com/foundry-rs/foundry";
    license = [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    maintainers = [ ];
  };
}
