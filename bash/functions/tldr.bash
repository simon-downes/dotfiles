#!/bin/bash
#
# Shows TLDR pages for a given topic

function tldr {

    TOPIC=$1

    if [ -z "${TOPIC}"  ]; then
        echo "Usage: $0 <topic>"
        return
    fi

    curl cheat.sh/${TOPIC}
    echo

}
