#! /bin/bash
set -e
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $_SCRIPT_DIR/config.sh

# options
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--daemonize)
      _DAEMONIZE="-daemonize"
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

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
	 $_DAEMONIZE
popd
