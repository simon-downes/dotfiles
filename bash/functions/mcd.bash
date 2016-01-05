#!/bin/bash
#
# Creates a directory and moves into it
#
function mcd() {
	mkdir -p $1 && cd $1
}