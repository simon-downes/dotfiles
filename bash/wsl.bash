#!/bin/bash

# if we're not running on Windows then don't do anything
grep -qsi Microsoft /proc/sys/kernel/osrelease || return;

# we should have an xserver running (hopefully) so tell our gui apps where to go
export DISPLAY=:0
export LIBGL_ALWAYS_INDIRECT=1

# set umask to prevent files and directories being world rw (666/777)
# https://zzz.buzz/2016/10/09/notes-on-bash-on-ubuntu-on-windows-windows-subsystem-for-linux/
umask 022

# make sure we always start in our ubuntu home directory
cd ~
