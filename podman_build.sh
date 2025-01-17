#! /bin/bash
sudo apt -y install podman 
_IMG=qemu_aarch64
podman build -t $_IMG . && podman run -t $_IMG
