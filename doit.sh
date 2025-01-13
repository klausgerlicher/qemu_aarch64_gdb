#! /bin/bash
set -e
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $_SCRIPT_DIR/config.sh

# jettison everything
sudo rm -rf $_QEMU_VERSION build install exec $_SOURCE_CODE

sudo apt-get install -y ninja-build zlib1g zlib1g-dev libglib2.0-dev libpixman-1-dev
sudo apt-get install -y libslirp-dev cloud-image-utils libguestfs-tools sshpass libaio-dev

# get qemu source
_QEMU_DOWNLOAD_URL=https://download.qemu.org
wget $_QEMU_DOWNLOAD_URL/$_SOURCE_CODE
tar xvJf $_SOURCE_CODE
rm $_SOURCE_CODE

# all required folders
mkdir -p $_BUILD_DIR $_INST_DIR $_EXEC_DIR

# configure, build, install
pushd $_BUILD_DIR
$_SOURCE_DIR/configure \
    --prefix=$_INST_DIR \
    --disable-kvm \
    --enable-slirp \
    --enable-linux-aio \
    --target-list=aarch64-softmmu |& tee $_BUILD_DIR/configure.txt

make -j$(nproc) |& tee $_BUILD_DIR/made.txt
sudo make install |& tee $_BUILD_DIR/installed.txt
popd

# exec the VM
pushd $_EXEC_DIR
    # throw away any previous image
    rm $_IMG || true
    wget -O $_IMG $_CLOUD_IMG

    # get EFI firmware from qemu-system package
    cp /usr/share/qemu-efi-aarch64/QEMU_EFI.fd QEMU_EFI.fd

    # make EFI and variable store images
    dd if=/dev/zero of=flash1.img bs=1M count=64
    dd if=/dev/zero of=flash0.img bs=1M count=64
    dd if=QEMU_EFI.fd of=flash0.img conv=notrunc

    # make cloud config
    cat >user-data.yaml <<EOF
#cloud-config
password: $_PASSWORD
chpasswd: { expire: False }
ssh_pwauth: True
EOF

    cat >meta.yaml <<EOF
instance-id: iid-local01
local-hostname: $_HOSTNAME
EOF

# create cloud config image
cloud-localds seed.img user-data.yaml meta.yaml

# resize the cloud image so we can use as storage too
../install/bin/qemu-img info $_IMG
../install/bin/qemu-img convert -O qcow2 -o cluster_size=2M $_IMG $_IMG.qcow2

# remove original cloud image
rm $_IMG

# resize by 20GB
../install/bin/qemu-img resize $_IMG.qcow2 +15G

popd
