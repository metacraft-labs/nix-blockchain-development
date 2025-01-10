{ pkgs }:
with pkgs;
buildGoModule rec {
  pname = "go-opera";
  version = "1.1.3-rc.5";

  src = fetchgit {
    url = "https://github.com/Fantom-foundation/go-opera";
    rev = "v${version}";
    sha256 = "sha256-j2FSsMpWCrMo9PfkpGoCML4kPVlR3OlK+sSWER/dMVw=";
  };

  karalabe-usb = fetchgit {
    url = "https://github.com/karalabe/usb";
    rev = "v0.0.2";
    sha256 = "sha256-liXTgMnA0W5CwfOkqaVLdWmDdBK+7DSWLQZuSLVOt6w=";
  };
  doCheck = false;
  buildInputs = [ gcc-unwrapped ];
  CGO_CFLAGS = "-I${karalabe-usb} -I${karalabe-usb}/hidapi/hidapi -I${karalabe-usb}/libusb/libusb";

  # GIT_COMMIT = "e529a4e7317e2f02e284c194677b301bb640cd73";
  # GIT_DATE = "1669028682";
  # ldflags = "-s -w -X github.com/Fantom-foundation/go-opera/cmd/opera/launcher.gitCommit=$${GIT_COMMIT} -X github.com/Fantom-foundation/go-opera/cmd/opera/launcher.gitDate=$${GIT_DATE}";

  vendorHash = "sha256-FYOY7RwpLGm/0FldrXTKg2d68HzOmUQBt6EolQ2f3hA=";

  meta = with lib; {
    description = "Opera blockchain protocol secured by the Lachesis consensus algorithm ";
    homepage = "https://github.com/Fantom-foundation/go-opera";
    license = licenses.lgpl3;
  };
}
