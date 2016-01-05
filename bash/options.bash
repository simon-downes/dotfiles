#!/bin/bash

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Don't tab-complete an empty line - there's not really any use for it
shopt -s no_empty_cmd_completion