#!/bin/bash

# Make vim the default editor
export EDITOR="nano"

# Entries beginning with space aren't added into history, and duplicate
# entries will be erased (leaving the most recent entry).
export HISTCONTROL=ignoredups:ignorespace

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=10000
export HISTFILESIZE=10000

# Make paging output nicer
# - quit if one screen
# - ignore case in searches
# - output ANSI colour sequences
# - Merge consecutive blank lines into one
# - highlight new line on movement
# - don't clear the screen first
export PAGER="less -FiRswX"
export MANPAGER="less -FiRswX"