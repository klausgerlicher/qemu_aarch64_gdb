FROM ubuntu:24.04
MAINTAINER Klaus Gerlicher

RUN apt-get update
RUN apt-get install -y ninja-build zlib1g zlib1g-dev libglib2.0-dev \
    libpixman-1-dev python3-tomli  libslirp-dev cloud-image-utils \
    libguestfs-tools sshpass libaio-dev python3 python3-venv gcc \
    cmake gawk build-essential install-info info flex bison automake \
    libtool libgmp-dev libmpfr-dev git

ENV PROXY "http://proxy-dmz.intel.com:912"
ENV HTTP_PROXY "http://proxy-dmz.intel.com:911"
ENV HTTPS_PROXY "http://proxy-dmz.intel.com:912"
ENV NO_PROXY "intel.com,localhost"
ENV SOCKS_PROXY "http://proxy-dmz.intel.com:1080"
ENV FTP_PROXY "http://proxy-dmz.intel.com:21"

# add proxy to system to make it persistent for all users
RUN echo "HTTPS_PROXY=${HTTPS_PROXY}" >> /etc/environment
RUN echo "HTTP_PROXY=${HTTP_PROXY}" >> /etc/environment
RUN echo "PROXY=${PROXY}" >> /etc/environment
RUN echo "NO_PROXY=${NO_PROXY}" >> /etc/environment
RUN echo "SOCKS_PROXY=${SOCKS_PROXY}" >> /etc/environment
RUN echo "FTP_PROXY=${FTP_PROXY}" >> /etc/environment

RUN echo "https_proxy=${HTTPS_PROXY}" >> /etc/environment
RUN echo "http_proxy=${HTTP_PROXY}" >> /etc/environment
RUN echo "proxy=${PROXY}" >> /etc/environment
RUN echo "no_proxy=${NO_PROXY}" >> /etc/environment
RUN echo "socks_PROXY=${SOCKS_PROXY}" >> /etc/environment
RUN echo "ftp_proxy=${FTP_PROXY}" >> /etc/environment

# add proxy to apt
RUN echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" > /etc/apt/apt.conf.d/10proxy

ARG _QEMU_VERSION=qemu-9.2.0
ARG _SOURCE_CODE=$_QEMU_VERSION.tar.xz
ARG _QEMU_DOWNLOAD_URL=https://download.qemu.org
ARG _BUILD_DIR=/build
ARG _INST_DIR=/install
ARG _EXEC_DIR=/exec
ARG _SOURCE_DIR=/$_QEMU_VERSION

RUN wget -O $_SOURCE_CODE $_QEMU_DOWNLOAD_URL/$_SOURCE_CODE
RUN tar xvf $_SOURCE_CODE || true
RUN rm $_SOURCE_CODE

RUN mkdir -p $_BUILD_DIR $_INST_DIR $_EXEC_DIR

# configure, build, install
RUN cd $_BUILD_DIR; $_SOURCE_DIR/configure \
        --prefix=$_INST_DIR \
        --disable-kvm \
        --enable-slirp \
        --enable-linux-aio \
        --target-list=aarch64-softmmu 
RUN cd $_BUILD_DIR; make -j$(nproc)
RUN cd $_BUILD_DIR; make install

# build the VM image
ARG _IMG=cloud.img
ARG _CLOUD_IMG=https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img

# download the image
RUN wget -O $_EXEC_DIR/$_IMG $_CLOUD_IMG

# make EFI and variable store images
RUN dd if=/dev/zero of=$_EXEC_DIR/flash1.img bs=1M count=64
RUN dd if=/dev/zero of=$_EXEC_DIR/flash0.img bs=1M count=64

COPY QEMU_EFI.fd $_EXEC_DIR

RUN dd if=$_EXEC_DIR/QEMU_EFI.fd of=$_EXEC_DIR/flash0.img conv=notrunc

COPY user-data.yaml /
COPY meta.yaml /

# create cloud config image
RUN cloud-localds $_EXEC_DIR/seed.img user-data.yaml meta.yaml

# resize the cloud image so we can use as storage too
RUN $_INST_DIR/bin/qemu-img info $_EXEC_DIR/$_IMG
RUN $_INST_DIR/bin/qemu-img convert -O qcow2 -o cluster_size=2M $_EXEC_DIR/$_IMG $_EXEC_DIR/$_IMG.qcow2

# remove original cloud image
RUN rm $_EXEC_DIR/$_IMG || true

# resize by 20GB
RUN $_INST_DIR/bin/qemu-img resize $_EXEC_DIR/$_IMG.qcow2 +15G

COPY *.sh /

ENV _IMG=$_EXEC_DIR/cloud.img

CMD ["./start.sh", "./setup.sh"] 