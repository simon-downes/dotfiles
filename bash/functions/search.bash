#!/bin/bash
#
# Search files for a specific string
#
function search {
    if [ $# -lt 3 ]; then
        echo "Usage: search <path> <files> <term>"
        return
    fi
    eval grep -Rni --color=always --include="'*.$2'" "'$3'" $1
}
