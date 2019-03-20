#!/bin/bash
#
# Shows network connection attempts

function tcpio {

    echo -n "Looking for connection attempts"
    Q="\"tcp[tcpflags] == tcp-syn\""

    PORT=$1

    if [ -n "${PORT}"  ]; then
        echo -n " on port ${PORT}"
        Q="${Q} and dst port ${PORT}"
    fi
    echo

    CMD="tcpdump --immediate-mode -lqi any -n ${Q}"

    echo "Executing: ${CMD}"
    echo "--------------------------------------------------------------------------------"
    echo

    eval ${CMD}

}
