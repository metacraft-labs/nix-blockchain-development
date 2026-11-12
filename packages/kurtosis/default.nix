{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "kurtosis";
  version = "api/golang/v1.22.2";

  src = fetchFromGitHub {
    owner = "kurtosis-tech";
    repo = "kurtosis";
    rev = version;
    hash = "sha256-mOH+c5nUHnSirgIqRWIMiZmny1I/c7LOUsxo7yh7I0Q=";
  };

  prePatch = ''
    patchShebangs scripts
  '';
  preConfigure = ''
    ./scripts/generate-kurtosis-version.sh "${version}"
  '';

  subPackages = [ "cli/cli" ];

  proxyVendor = true;
  vendorHash = "sha256-zhfkwe3X2gStujfDBh5+j92UW4JsMC+fmNMfEQwOKlA=";

  installPhase = ''
    install -Dm 755 $GOPATH/bin/cli $out/bin/kurtosis
  '';

  meta = with lib; {
    description = "A platform for packaging and launching ephemeral backend stacks with a focus on approachability for the average developer";
    homepage = "https://github.com/kurtosis-tech/kurtosis";
    changelog = "https://github.com/kurtosis-tech/kurtosis/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "kurtosis";
    platforms = platforms.all;
  };
}
