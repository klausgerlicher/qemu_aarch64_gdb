#! /bin/bash
set -e
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $_SCRIPT_DIR/config.sh

pushd $_EXEC_DIR
     $_INST_DIR/bin/qemu-system-aarch64 \
         -smp $(( $(nproc) / 2 )) \
         -m 4G \
         -M virt \
         -cpu max,sme=on \
         -device virtio-blk-device,drive=image \
         -drive if=none,id=image,file=$_IMG.qcow2 \
         -object iothread,id=io1 \
         -device virtio-blk-device,drive=cloud,iothread=io1 \
         -drive if=none,id=cloud,aio=threads,file=seed.img \
         -device e1000,netdev=net0 \
         -netdev user,id=net0,hostfwd=tcp::5555-:22 \
         -pflash flash0.img \
         -pflash flash1.img \
         -vnc :0 -monitor stdio
popd
