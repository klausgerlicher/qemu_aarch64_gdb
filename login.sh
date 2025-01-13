
#! /bin/bash
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $_SCRIPT_DIR/config.sh

function do_ssh()
{
 sshpass -p $_PASSWORD ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -v -p 5555 -t ubuntu@localhost $1
}

do_ssh

