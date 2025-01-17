# qemu_aarch64_gdb

Script set to create a QEMU aarch64 VM including a ready built GDB. This is for
GDB internal purposes.

# How to use

1) Run doit.sh. This will compile QEMU 9.x from scratch create a Qemu VM from an
Ubuntu 24.04 LTS cloud image.
2) Run start.sh to start this VM. Wait until it has entirely started which
should take about 5 min. Leave this terminal open. Add -d if you want this in
the background.
3) In another terminal Run setup.sh if you didn't "./start.sh -d" . This will
setup the VM to have a readily built GDB from upstream master. It will
also add the Thiago V4 patch currently.
4) When you want to work in this VM, use login.sh to login via SSH. Go to
/home/ubuntu/dev. There's a script mgdb.sh that will allow you to build GDB
again w/o configure. Now do what you need to do with it.

You can also make the QEMU VM accessible to the outside by running ./forward.sh.
It is then SSH reachable via port 5556 from your external machine. VS code remote
also works in this setup. Add ports 5556 to your VS code SSH config file.

# Grab bag

## How to access the running VM thru SSH
VM is running SSH at localhost:5555. You can  reach this from your local
host, see also below for external access.

User: ubuntu
Password: Quark128

## How to access the running VM thru SSH via a socat forwarder
VM is running SSH at localhost:5555.

socat TCP-LISTEN:5556,fork TCP:localhost:5555

You can use forward.sh also.

## VScode works also when specifying port 5556 in the connection config
Host QEMU_aarch64
  HostName <IP of your host>
  User ubuntu
  Port 5556 

## Running in WSL2

This also runs in WSL2. Simply check this out to a directory and do

## Docker/Podman containerization
1. install podman: sudo apt install podman
2. run podman_build.sh. This will build and run the QEMU in a container.

