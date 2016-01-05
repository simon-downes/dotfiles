#!/bin/bash
#
# Implode an array using a seperator (single character)
# http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
function implode {
	#local IFS="$1"; shift; echo "$*";
	local IFS=$1; echo "${*:2}";
}