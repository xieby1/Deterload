let
  name = "opensbi-common-build";
  pkgs = import <nixpkgs> {};
  dts = import ./dts;
in pkgs.stdenv.mkDerivation {
  inherit name;

  src = pkgs.fetchFromGitHub {
    owner = "riscv-software-src";
    repo = "opensbi";
    rev = "c4940a9517486413cd676fc8032bb55f9d4e2778";
    hash = "sha256-cV+2DJjlqdG9zR3W6cH6BIZqnuB1kdH3mjc4PO+VPeE=";
  };

  buildInputs = [
    pkgs.python3
    pkgs.pkgsCross.riscv64.stdenv.cc
  ];

  makeFlags = [
    "CROSS_COMPILE=riscv64-unknown-linux-gnu-"
    "PLATFORM=generic"
    "FW_FDT_PATH=${dts}/xiangshan.dtb"
    "FW_PAYLOAD_OFFSET=0x200000"
  ];
  buildPhase = ''
    patchShebangs .

    make -j $NIX_BUILD_CORES $makeFlags

    # Perform a minor cleanup to trigger the next make -j command for generating a new image.
    rm build/platform/generic/firmware/fw_payload.o
    rm build/platform/generic/firmware/fw_payload.elf*
    rm build/platform/generic/firmware/fw_payload.bin
  '';

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';
  dontFixup = true;
}
