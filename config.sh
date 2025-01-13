#! /bin/bash
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

_IMG=cloud.img
_CLOUD_IMG=https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img
_QEMU_VERSION=qemu-9.2.0
_SOURCE_CODE=$_QEMU_VERSION.tar.xz

_BUILD_DIR=$_SCRIPT_DIR/build
_INST_DIR=$_SCRIPT_DIR/install
_EXEC_DIR=$_SCRIPT_DIR/exec
_SOURCE_DIR=$_SCRIPT_DIR/$_QEMU_VERSION

_HOSTNAME=gdbuntu
_PASSWORD=Quark128