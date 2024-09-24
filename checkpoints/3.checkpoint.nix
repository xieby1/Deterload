{ runCommand
, lib
, testCase
, qemu
, nemu
, gcpt-bin
, stage2-cluster
}:
let
  name = "3.checkpoint-${testCase}";
  config = import ../config.nix;

  qemuCommand = [
    "${qemu}/bin/qemu-system-riscv64"
    "-bios ${gcpt-bin}/gcpt.${testCase}.bin"
    "-M nemu,simpoint-path=${stage2-cluster},workload=.,cpt-interval=${toString config.intervals},output-base-dir=$out,config-name=${config.workload},checkpoint-mode=SimpointCheckpoint"
    "-nographic"
    "-m 8G"
    "-smp 1"
    "-cpu rv64,v=true,vlen=128,h=false,sv39=true,sv48=false,sv57=false,sv64=false"
    "-icount shift=0,align=off,sleep=off"
  ];

  nemuCommand = [
    "${nemu}/bin/riscv64-nemu-interpreter"
    "${gcpt-bin}/gcpt.${testCase}.bin"
    "-b"
    "-D $out"
    "-C checkpoint"
    "-w ${config.workload}"
    "-S ${stage2-cluster}"
    "--cpt-interval ${toString config.intervals}"
  ];

in runCommand name {} ''
  mkdir -p $out

 ${if config.simulator == "qemu" then ''
    echo "Executing QEMU command:"
    ${builtins.toString qemuCommand} | tee $out/${config.checkpoint_log}
  '' else ''
    echo "Executing NEMU command:"
    ${builtins.toString nemuCommand} | tee $out/${config.checkpoint_log}
  ''}
''