{
  lib,
  nasm,
  ffiasm-src,
  nodejs,
  stdenvNoCC,
}: {
  primeNumber,
  name,
}: let
  filename = lib.toLower name;

  buildNasm =
    if stdenvNoCC.isDarwin
    then ''
      nasm -fmacho64 --prefix _ ${filename}.asm
    ''
    else ''
      nasm -felf64 ${filename}.asm
    '';
in
  stdenvNoCC.mkDerivation {
    name = "zqfield-${filename}";
    unpackPhase = ":";
    nativeBuildInputs = [nasm ffiasm-src];
    buildPhase =
      ''
        ${ffiasm-src}/bin/buildzqfield -q '${primeNumber}' -n ${name}
      ''
      + buildNasm;
    installPhase = ''
      mkdir -p $out/lib
      cp ${filename}.{asm,cpp,hpp,o} $out/lib/
    '';

    dontFixup = true;
  }
