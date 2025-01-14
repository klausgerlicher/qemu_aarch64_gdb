#! /bin/bash
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $_SCRIPT_DIR/config.sh

function do_scp()
{
   sshpass -p $_PASSWORD scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -v -P 5555 $1 ubuntu@localhost:$2
}

do_scp $1 $2
