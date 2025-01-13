
#! /bin/bash
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $_SCRIPT_DIR/config.sh

function do_ssh()
{
 sshpass -p $_PASSWORD ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -v -p 5555 -t ubuntu@localhost $1
}

function do_scp()
{
   sshpass -p $_PASSWORD scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -v -P 5555 $1 ubuntu@localhost:$2
}

until sshpass -p $_PASSWORD ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oConnectTimeout=2 -p 5555 ubuntu@localhost exit; do
     echo "waiting for VM up..."
     sleep 2
done

do_ssh 'mkdir -p /home/ubuntu/dev; rm -rf /home/ubuntu/dev/builds'
do_scp $_SCRIPT_DIR/proxies /home/ubuntu/dev/
do_scp $_SCRIPT_DIR/build-gdb.sh /home/ubuntu/dev/
do_scp $_SCRIPT_DIR/bconfig.sh /home/ubuntu/dev/

# install build requirements
do_ssh 'sudo apt-get update'
do_ssh 'sudo apt-get install -y git cmake gawk build-essential texinfo flex bison mc automake libtool dejagnu libgmp-dev libmpfr-dev ncurses-dev python3 python3-dev'
# fetch GDB source
do_ssh 'cd /home/ubuntu/dev; source proxies; git clone https://sourceware.org/git/binutils-gdb.git gdb'
# build GDB
do_ssh 'cd /home/ubuntu/dev; ./build-gdb.sh'

