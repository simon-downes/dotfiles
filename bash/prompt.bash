#!/bin/bash

function __build_prompt() {

    # must come first
    local __exit=$?

    # define prompt colour sequences
    # https://unix.stackexchange.com/questions/158412/are-the-terminal-color-escape-sequences-defined-anywhere-for-bash
    local __red="\[$(tput setaf 1)\]"
    local __green="\[$(tput setaf 2)\]"
    local __yellow="\[$(tput setaf 3)\]"
    local __blue="\[$(tput setaf 4)\]"
    local __magenta="\[$(tput setaf 5)\]"
    local __cyan="\[$(tput setaf 6)\]"
    local __white="\[$(tput setaf 7)\]"
    local __gray="\[$(tput setaf 8)\]"

    local __bright_red="\[$(tput setaf 9)\]"
    local __bright_green="\[$(tput setaf 10)\]"
    local __bright_yellow="\[$(tput setaf 11)\]"
    local __bright_blue="\[$(tput setaf 12)\]"
    local __bright_magenta="\[$(tput setaf 13)\]"
    local __bright_cyan="\[$(tput setaf 14)\]"
    local __bright_white="\[$(tput setaf 15)\]"

    local __bold="\[$(tput bold)\]"
    local __underline="\[$(tput sgr 0 1)\]"
    local __invert="\[$(tput sgr 1 0)\]"
    local __nocolour="\[$(tput sgr0)\]"

    # default prompt colour is green to indicate success of previous command
    local __prompt_colour="${__green}"

    # if last command failed then prompt is red and includes exit code
    if [ $__exit != 0 ]; then
        __prompt_colour="${__red}"
        __exit="${__prompt_colour}❌${__exit} ${__nocolour}"
    else
        __exit="${__prompt_colour}✔ ${__nocolour}"
    fi

    # character definitions
    local __box_top="${__prompt_colour}╭ ${__nocolour}"
    local __box_bottom="${__prompt_colour}╰ ${__nocolour}"
    local __prompt_char="${__prompt_colour}❯ ${__nocolour}"
    local __separator="${__bright_white} :: ${__nocolour}"
    local __git_separator="${__nocolour}•"

    if [ $USER == "root" ]; then
        local __user=${__bright_red}${USER}${__nocolour}
    else
        local __user=${__yellow}${USER}${__nocolour}
    fi

    local __host="${__bright_magenta}${HOSTNAME}${__nocolour}"

    local __current_dir="${__bright_blue}\\w${__nocolour}"

    local __git_status=""

    # determine if we're in a git work tree:
    # empty string = not in a git repo
    # true = in a git repo - not in the .git directory
    # false = in the .git directory of a git repo
    local __git_work_tree=$(git rev-parse --is-inside-work-tree 2> /dev/null)

    if [ ! -z "${__git_work_tree}" ]; then

        # check for what branch we're on. (fast)
        #   if… HEAD isn’t a symbolic ref (typical branch),
        #   then… get a tracking remote branch or tag
        #   otherwise… get the short SHA for the latest commit
        #   lastly just give up.
        local __git_branch="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
            git describe --all --exact-match HEAD 2> /dev/null || \
            git rev-parse --short HEAD 2> /dev/null || \
            echo '(unknown)')";

        local __git_changes=""

        if [ $__git_work_tree = "true" ]; then

            # get number of staged but not commited files
            local __git_staged=$(git diff-index --cached HEAD -- 2> /dev/null | wc -l)

            # number of unstaged files
            local __git_unstaged=$(git diff-files --ignore-submodules | wc -l)

            # number of untracked files (that aren't ignored)
            local __git_untracked=$(git ls-files --others --exclude-standard | wc -l)

            __git_changes=" ${__green}${__git_staged}${__git_separator}${__yellow}${__git_unstaged}${__git_separator}${__cyan}${__git_untracked}${__no_colour}"
        fi

        # combine the git info into a single string
        __git_status="${__separator}${__red}${__git_branch}${__git_changes}${__no_colour}"

    fi

    PS1="\n${__box_top}${__user}@${__host}${__separator}${__current_dir}${__git_status}\n${__box_bottom}${__exit}${__prompt_char}"

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
