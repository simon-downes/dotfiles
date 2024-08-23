
# not running interactively so don't do anything
[[ $- == *i* ]] || return 0

# if we have SiBash available then we'll include that and use sb.session
SIBASH=$(command -v sibash)

[ -n "$SIBASH" ] && {
    . $SIBASH
    sb.session.init
    return
}

# --------------------------------------------------------------------------
# This is a cut-down version of what's in SiBash's sb.session
# It focuses on core options, exports, aliases and a cutdown prompt
# It's perfectly usable but sb.session is better ;)
# --------------------------------------------------------------------------

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Don't tab-complete an empty line - there's not really any use for it
shopt -s no_empty_cmd_completion

# Make nano the default editor
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
# - set tabs to 4 spaces
export LESS='-FiRswXx4'
export PAGER="less -FiRswXx4"
export MANPAGER="less -FiRswXx4"

# Allow aliases to be used with sudo
alias sudo="sudo "

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# standard ls setup
alias ls='ls -l --group-directories-first'

# better nano
# show line numbers, cursor position, "scrollbar" and stateflags
# convert tabs to 4 spaces, auto-indent, smarter home key, don't wrap lines
alias nano="nano --linenumbers --constantshow --indicator --stateflags --autoindent --smarthome --tabstospaces --tabsize=4 --historylog --nowrap"

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

# git aliases
command -v git > /dev/null && {
    alias g="git status"
    alias gl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    alias ga="git add"
    alias gc="git commit -m"
    alias gd="git diff"
    alias gdc="git diff --cached"
    alias gpo="git push origin"
}

function __build_prompt {

    # must come first - grab exit code of last command
    local _exit=$?

    # define prompt colour sequences - needs surround square brackets
    # https://unix.stackexchange.com/questions/158412/are-the-terminal-color-escape-sequences-defined-anywhere-for-bash
    local red="\[$(tput setaf 1)\]"
    local green="\[$(tput setaf 2)\]"
    local yellow="\[$(tput setaf 3)\]"
    local blue="\[$(tput setaf 4)\]"
    local magenta="\[$(tput setaf 5)\]"
    local cyan="\[$(tput setaf 6)\]"
    local white="\[$(tput setaf 7)\]"
    local gray="\[$(tput setaf 8)\]"

    local bright_red="\[$(tput setaf 9)\]"
    local bright_green="\[$(tput setaf 10)\]"
    local bright_yellow="\[$(tput setaf 11)\]"
    local bright_blue="\[$(tput setaf 12)\]"
    local bright_magenta="\[$(tput setaf 13)\]"
    local bright_cyan="\[$(tput setaf 14)\]"
    local bright_white="\[$(tput setaf 15)\]"

    local bold="\[$(tput bold)\]"
    local underline="\[$(tput sgr 0 1)\]"
    local invert="\[$(tput sgr 1 0)\]"
    local reset="\[$(tput sgr0)\]"

    # default prompt colour is green to indicate success of previous command
    local prompt_colour="${green}"

    # if last command failed then prompt is red and includes exit code
    if [ $_exit != 0 ]; then
        prompt_colour="${red}"
        _exit="${prompt_colour}🗙 ${_exit} ${reset}"
    else
        _exit="${prompt_colour}✔ ${reset}"
    fi

    # character definitions
    local box_top="${prompt_colour}╭ ${reset}"
    local box_bottom="${prompt_colour}╰ ${reset}"
    local prompt_char="${prompt_colour}❯ ${reset}"
    local separator="${bright_white} :: ${reset}"
    local git_separator="${reset}•"

    if [ $USER == "root" ]; then
        local user=${bright_red}${USER}${reset}
    else
        local user=${yellow}${USER}${reset}
    fi

    local host="${bright_magenta}${HOSTNAME}${reset}"

    local current_dir="${bright_blue}\\w${reset}"

    local git_status=""

    command -v git > /dev/null && {

        # determine if we're in a git work tree:
        # empty string = not in a git repo
        # true = in a git repo - not in the .git directory
        # false = in the .git directory of a git repo
        local git_work_tree=$(git rev-parse --is-inside-work-tree 2> /dev/null)

        if [ -n "${git_work_tree}" ]; then

            # check for what branch we're on. (fast)
            #   if… HEAD isn’t a symbolic ref (typical branch),
            #   then… get a tracking remote branch or tag
            #   otherwise… get the short SHA for the latest commit
            #   lastly just give up.
            local git_branch="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
                git describe --all --exact-match HEAD 2> /dev/null || \
                git rev-parse --short HEAD 2> /dev/null || \
                echo '(unknown)')";

            # combine the git info into a single string
            git_status="${separator}${red}${git_branch}${reset}"

        fi

    }

    PS1="\n${box_top}${user}@${host}${separator}${current_dir}${git_status}\n${box_bottom}${_exit}${prompt_char}"

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
        xterm*|rxvt*)
            PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
        *)
        ;;
    esac

}

PROMPT_COMMAND=__build_prompt

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable auto-completion if possible
if ! shopt -oq posix; then
    [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
fi

# WSL stuff
# https://stackoverflow.com/questions/61110603/how-to-set-up-working-x11-forwarding-on-wsl2
grep -qsi Microsoft /proc/sys/kernel/osrelease && {
    # we should have an xserver running (hopefully) so tell our gui apps where to go
    export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
    export LIBGL_ALWAYS_INDIRECT=1
}

# some form of local config
[ -f ~/.bash.local ] && . ~/.bash.local

# ensure we get a green prompt to start with
true
