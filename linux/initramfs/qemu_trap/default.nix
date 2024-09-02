let
  name = "qemu_trap";
  pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation rec {
  inherit name;
  src = builtins.fetchurl {
    url = "https://github.com/OpenXiangShan/riscv-rootfs/raw/da983ec95858dfd6f30e9feadd534b79db37e618/apps/qemu_trap/qemu_trap.c";
    sha256 = "0ray1gq841m8n6kyhp2ncj6aa7nw3lwwy3mfjh3848hsy7583vky";
  };
  dontUnpack = true;
  buildInputs = [
    pkgs.pkgsCross.riscv64.stdenv.cc
    pkgs.pkgsCross.riscv64.stdenv.cc.libc.static
  ];
  buildPhase = ''
    riscv64-unknown-linux-gnu-gcc ${src} -o ${name} -static
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${name} $out/bin/
  '';
}
