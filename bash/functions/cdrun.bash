#!/bin/bash
function cdrun {
    ( cd "$1" && shift && command "$@" )
}
