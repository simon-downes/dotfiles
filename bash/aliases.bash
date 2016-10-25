#!/bin/bash

# https://github.com/necolas/dotfiles/blob/master/shell/bash_aliases

# Allow aliases to be used with sudo
alias sudo="sudo "

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# standard ls setup
alias ls='ls -l --group-directories-first'

# list only hidden files
alias lh='ls -d .*'

# list only directories
alias lsd="ls -F | grep --color=never '^d'"

# Show $PATH in a readable way
alias path='echo -e ${PATH//:/\\n}'

# quick access to hosts file
alias hosts='sudo $EDITOR /etc/hosts'

# Get your current public IP
alias ip="curl icanhazip.com"

alias messages='sudo tail -f /var/log/messages'
alias err='sudo tail -f /var/log/apache2-dev/simon.error.log'

# enable color support of ls and also add handy aliases
# http://linux.die.net/man/1/dircolors
# http://www.gnu.org/software/coreutils/manual/html_node/dircolors-invocation.html#dircolors-invocation
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -l --group-directories-first --color=always'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# Package Management
alias apt-update="sudo apt-get -qq update && sudo apt-get upgrade"
alias apt-install="sudo apt-get install"
alias apt-remove="sudo apt-get remove"
alias apt-search="apt-cache search"

# git
alias gl="git lg"
alias ga="git add"
alias gc="git commit -m"
alias gd="git diff"
alias gdc="git diff --cached"
alias gpo="git push origin"
