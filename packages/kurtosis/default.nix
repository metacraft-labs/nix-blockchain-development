{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "kurtosis";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "kurtosis-tech";
    repo = "kurtosis";
    rev = version;
    hash = "sha256-oR6Nuw4RZhHGV4k6hFVxK+0wk3Noq7F9VBHUYxdeGa4=";
  };

  prePatch = ''
    patchShebangs scripts
  '';
  preConfigure = ''
    ./scripts/generate-kurtosis-version.sh "${version}"
  '';

  subPackages = [ "cli/cli" ];

  proxyVendor = true;
  vendorHash = "sha256-0LMsy8Xp/8fbtH41hpEEBfzmOplUjrRgTor0cYEg8zw=";

  installPhase = ''
    install -Dm 755 $GOPATH/bin/cli $out/bin/kurtosis
  '';

  meta = with lib; {
    description = "A platform for packaging and launching ephemeral backend stacks with a focus on approachability for the average developer";
    homepage = "https://github.com/kurtosis-tech/kurtosis";
    changelog = "https://github.com/kurtosis-tech/kurtosis/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "kurtosis";
    platforms = platforms.all;
  };
}
