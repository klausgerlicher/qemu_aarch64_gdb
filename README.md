# qemu_aarch64_gdb

Script set to create a QEMU aarch64 VM including a ready built GDB. This is for
GDB internal purposes.

# Howto use

1) Run doit.sh. This will compile QEMU 9.x from scratch create a Qemu VM from an
Ubuntu 24.04 LTS cloud image.
2) Run start.sh to start this VM. Wait until it has entirely started which
should take about 5 min. Leave this terminal open. 
3) In another terminal Run setup.sh. This will setup the VM to have a readily built GDB from
upstream master.

Now when you want to work in this VM, use login.sh to login via SSH. Go to
/home/ubuntu/dev. There's a script mgdb.sh that will allow you to build GDB
again w/o configure. Now do what you need to do with it.

# Grab bag

## How to access the running VM thru SSH
VM is running SSH at localhost:5555. You can  reach this from your local
host, see also below for external access.

User: ubuntu
Password: Quark128

## How to access the running VM thru SSH via a socat forwarder
VM is running SSH at localhost:5555.

socat TCP-LISTEN:5556,fork TCP:localhost:5555

## VScode works also when specifying port 5555 in the connection config
Host QEMU_aarch64
  HostName <IP of your host>
  User ubuntu
  Port 5556 


