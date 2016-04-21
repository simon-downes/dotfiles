
# If possible, add tab completion for many commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# TODO: any other tab completion stuff goes here...

# Autocompletion for git aliases
# http://stackoverflow.com/questions/342969/how-do-i-get-bash-completion-to-work-with-aliases
if [ -f ~/.git-completion.bash ]; then

	. ~/.git-completion.bash

	__git_complete gl _git_log
	__git_complete ga _git_add
	__git_complete gd _git_diff
	__git_complete gdc _git_diff

fi
