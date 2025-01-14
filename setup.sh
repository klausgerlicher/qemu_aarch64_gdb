#! /bin/bash
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $_SCRIPT_DIR/config.sh

while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      _VERBOSE_FLAG="-v"
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done


function do_ssh()
{
 sshpass -p $_PASSWORD ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $_VERBOSE_FLAG -p 5555 -t ubuntu@localhost $1
}

function do_scp()
{
   sshpass -p $_PASSWORD scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $_VERBOSE_FLAG -P 5555 $1 ubuntu@localhost:$2
}

until sshpass -p $_PASSWORD ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oConnectTimeout=2 -p 5555 ubuntu@localhost exit; do
     echo "waiting for VM up..."
     sleep 2
done

_QEMU_DEV_FOLDER=/home/ubuntu/dev/
do_ssh "rm -rf $_QEMU_DEV_FOLDER/builds; mkdir -p $_QEMU_DEV_FOLDER"
do_scp $_SCRIPT_DIR/proxies $_QEMU_DEV_FOLDER
do_scp $_SCRIPT_DIR/build-gdb.sh $_QEMU_DEV_FOLDER
do_scp $_SCRIPT_DIR/bconfig.sh $_QEMU_DEV_FOLDER

# install build requirements
do_ssh 'sudo apt-get update'
do_ssh 'sudo apt-get install -y git cmake gawk build-essential texinfo flex bison mc automake libtool dejagnu libgmp-dev libmpfr-dev ncurses-dev python3 python3-dev'

# fetch GDB source
do_ssh "cd $_QEMU_DEV_FOLDER; source $_QEMU_DEV_FOLDER/proxies; git clone https://sourceware.org/git/binutils-gdb.git gdb"

# set user in git (maybe make this configurable but use mine for now)
do_ssh "cd $_QEMU_DEV_FOLDER/gdb; git config --global user.email 'klaus.gerlicher@intel.com'; git config --global user.name 'Klaus Gerlicher'"

# get Thiago v4 patch and push it to qemu
_PATCH_NAME="thiagov4.patch"
wget -O $_SCRIPT_DIR/$_PATCH_NAME https://patchwork.sourceware.org/series/40207/mbox/
do_scp $_SCRIPT_DIR/$_PATCH_NAME $_QEMU_DEV_FOLDER
rm $_SCRIPT_DIR/$_PATCH_NAME

# checkout Thiago V4 branch and apply patch
do_ssh "cd $_QEMU_DEV_FOLDER/gdb; git checkout -B thiago_v4 893e4fd6231; git am $_QEMU_DEV_FOLDER/$_PATCH_NAME"

# now build GDB
do_ssh "cd $_QEMU_DEV_FOLDER; ./build-gdb.sh"

