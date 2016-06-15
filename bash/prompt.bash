#!/bin/bash


# zsh style right prompt support :)
#__rprompt() {
#    printf "%*s\r" "$COLUMNS" "$(eval echo "$RPROMPT")"
#}

#if [[ ! $PROMPT_COMMAND =~ __rprompt ]]; then
#    export PROMPT_COMMAND="__rprompt; ${PROMPT_COMMAND:-:}"
#fi

#export RPROMPT='$(date)'

#TODO: https://github.com/gabrielelana/awesome-terminal-fonts

PROMPT_CHAR="❯"

GIT_CLEAN="✔"
GIT_DELIMITER="•"

# GIT_CLEAN="✔"
# GIT_DIRTY="✖"
# GIT_UNTRACKED="●"
# GIT_AHEAD="↑"
# GIT_BEHIND="↓"


# GIT_CLEAN="✔"
# GIT_STAGED="•"
# GIT_UNMERGED="✖"
# GIT_UNSTAGED=""
# GIT_UNTRACKED="…"
GIT_AHEAD="↑"
GIT_BEHIND="↓"


# Local Status Symbols

# Symbol	Meaning
# ✔	repository clean
# ●n	there are n staged files
# ✖n	there are n unmerged files
# ✚n	there are n changed but unstaged files
# …	there are some untracked files
# Branch Tracking Symbols

# Symbol	Meaning
# ↑n	ahead of remote by n commits
# ↓n	behind remote by n commits
# ↓m↑n	branches diverged, other by m commits, yours by n commits

function __build_prompt() {

	local LOCAL_USER="simon"

	# Local or SSH session?
	local REMOTE=""
	[ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && REMOTE=1

	# Only show username if not default
	local USER_PROMPT=
	[ "$USER" != "$LOCAL_USER" ] && USER_PROMPT="$NOCOLOUR$RED$BOLD$USER"

	# Show hostname inside SSH session
	local HOST_PROMPT=
	[ -n "$REMOTE" ] && HOST_PROMPT="$NOCOLOUR@$MAGENTA$BOLD$HOSTNAME"

	# Show delimiter if user or host visible
	local LOGIN_DELIMITER=
	[ -n "$USER_PROMPT" ] || [ -n "$HOST_PROMPT" ] && LOGIN_DELIMITER="$NOCOLOUR:"

	local GIT_PROMPT=$(__git_prompt)

	PS1="${USER_PROMPT}${HOST_PROMPT}${LOGIN_DELIMITER}$BLUE$BOLD\w$GIT_PROMPT$RED$BOLD❯$NOCOLOUR "

	# If this is an xterm set the title to user@host:dir
	case "$TERM" in
		xterm*|rxvt*)
			PS1="\[\e]0;\u@\h: \w\a\]$PS1"
		;;
		*)
		;;
	esac

}

function __git_prompt() {

	# check if we're in a git repo. (fast)
	local IS_WORK_TREE="$(git rev-parse --is-inside-work-tree 2> /dev/null)"

	# not a git directory so do nothing
	[ -z $IS_WORK_TREE ] && return

	# check for what branch we're on. (fast)
	#   if… HEAD isn’t a symbolic ref (typical branch),
	#   then… get a tracking remote branch or tag
	#   otherwise… get the short SHA for the latest commit
	#   lastly just give up.
	local BRANCH="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
		git describe --all --exact-match HEAD 2> /dev/null || \
		git rev-parse --short HEAD 2> /dev/null || \
		echo '(unknown)')";
	
	local GIT_PROMPT="$NOCOLOUR:$RED$BRANCH$NOCOLOUR"

	# only show all the status info if we're in the work tree, not the git dir
	if [ "$IS_WORK_TREE" = "true" ]; then

		# get number of staged but not commited files
		local STAGED=$(git diff-index --cached HEAD -- 2> /dev/null | wc -l)

		# number of unstaged files
		local UNSTAGED=$(git diff-files --ignore-submodules | wc -l)

		# number of untracked files (that aren't ignored)
		local UNTRACKED=$(git ls-files --others --exclude-standard | wc -l)

		local GIT_PROMPT="$GIT_PROMPT $GREEN$STAGED$NOCOLOUR$GIT_DELIMITER$YELLOW$UNSTAGED$NOCOLOUR$GIT_DELIMITER$CYAN$UNTRACKED"

		if [ git rev-parse --abbrev-ref @'{u}' 2> /dev/null ]; then
			local UPSTREAM=$(git rev-list --left-right --count HEAD...@'{u}')
			local AHEAD=$(echo $UPSTREAM | cut -d" " -f1)
			local BEHIND=$(echo $UPSTREAM | cut -d" " -f2)
			if [ $AHEAD -gt 0 ]; then
				GIT_PROMPT="$GIT_PROMPT $NOCOLOUR$GREEN$AHEAD$GIT_AHEAD"
			fi
			if [ $BEHIND -gt 0 ]; then
				GIT_PROMPT="$GIT_PROMPT $NOCOLOUR$RED$BEHIND$GIT_BEHIND"
			fi
		fi

	fi

	echo $GIT_PROMPT

	# Check for stashed files.
	# if $(git rev-parse --verify refs/stash &>/dev/null); then
	# 	s+='$';
	# fi;

}

PROMPT_COMMAND=__build_prompt

# if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# # We have color support; assume it's compliant with Ecma-48
# # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# # a case would tend to support setf rather than setaf.)
# 	#PS1="\[\033[01;31m\]\u\[\033[00m\]@\[\033[01;35m\]\h\[\033[01;34m\] \w\[\033[00m\]> "
# 	PS1="$BOLD$RED\u$NOCOLOUR@$BOLD$MAGENTA\h $BLUE\w$NOCOLOUR$RED☀ $NOCOLOUR❯ "
# else
# 	PS1="\u@\h\ \w> "
# fi
