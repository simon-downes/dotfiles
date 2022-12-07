
# not running interactively so don't do anything
[[ $- == *i* ]] || return 0

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
GRAY=$(tput setaf 8)
BOLD=$(tput bold)
UNDERLINE=$(tput sgr 0 1)
INVERT=$(tput sgr 1 0)
NOCOLOUR=$(tput sgr0)

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

# if we're on WSL then do some special stuff for that
grep -qsi Microsoft /proc/sys/kernel/osrelease && . ~/dotfiles/bash/wsl.bash;

# if we have aws-vault installed then set the backend to file and create an alias
# that will cat the password from a file to an env var when the command is run
if [ $(which aws-vault) ]; then
    export AWS_VAULT_BACKEND="file"
    alias av='eval AWS_VAULT_FILE_PASSPHRASE=$(cat ~/.awsvault/pw) aws-vault'
fi

# some form of local config
[ -f ~/.bash.local ] && . ~/.bash.local
