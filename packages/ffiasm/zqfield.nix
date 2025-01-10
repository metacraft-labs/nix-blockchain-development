{
  lib,
  nasm,
  ffiasm-src,
  runCommand,
  hostPlatform,
}:
{
  primeNumber,
  name,
}:
let
  filename = lib.toLower name;
  nasmArgs = if hostPlatform.isDarwin then "-fmacho64 --prefix _" else "-felf64";
in
runCommand "zqfield-${filename}-${primeNumber}" { } ''
  ${lib.getExe ffiasm-src} -q ${primeNumber} -n ${name}
  ${nasm}/bin/nasm ${nasmArgs} ${filename}.asm
  mkdir -p $out/lib
  cp ${filename}.{asm,cpp,hpp,o} $out/lib/
''
