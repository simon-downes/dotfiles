
# not running interactively so don't do anything
[[ $- == *i* ]] || return 0

RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
MAGENTA="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
GRAY="\[$(tput setaf 8)\]"
BOLD="\[$(tput bold)\]"
UNDERLINE="\[$(tput sgr 0 1)\]"
INVERT="\[$(tput sgr 1 0)\]"
NOCOLOUR="\[$(tput sgr0)\]"

. ~/dotfiles/bash/options.bash
. ~/dotfiles/bash/exports.bash
. ~/dotfiles/bash/aliases.bash

# source all file in ~/dotfiles/bash/functions
for func in ~/dotfiles/bash/functions/*; do
	. $func
done

. ~/dotfiles/bash/prompt.bash
. ~/dotfiles/bash/completion.bash

# TODO: move to misc?
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# some form of local config
[ -f ~/.bash.local ] && . ~/.bash.local