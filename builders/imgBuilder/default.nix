{ pkgs
, benchmark
}: let
  riscv64-cc = pkgs.pkgsCross.riscv64.stdenv.cc;
  riscv64-libc-static = pkgs.pkgsCross.riscv64.stdenv.cc.libc.static;
  riscv64-busybox = pkgs.pkgsCross.riscv64.busybox.override {
    enableStatic = true;
    useMusl = true;
  };
  gcpt = pkgs.callPackage ./gcpt {
    inherit riscv64-cc riscv64-libc-static riscv64-busybox;
    inherit benchmark;
  };
in gcpt.overrideAttrs (old: {
  passthru = {
    inherit riscv64-cc riscv64-libc-static riscv64-busybox benchmark;
  };
})