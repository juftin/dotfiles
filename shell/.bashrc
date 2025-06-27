#########################################################################################################

# Amazon Q
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash" ]]; then
	builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash"
fi

# shell-startup
[[ ! -f "${HOME}/.shell_startup" ]] || source "${HOME}/.shell_startup"

##########################################################
############### ENV / ALIASES / FUNCTIONS ################
##########################################################

# variables
[[ ! -f "${HOME}/.shell_vars" ]] || source "${HOME}/.shell_vars"
[[ ! -f "${HOME}/.bashenv" ]] || source "${HOME}/.bashenv"
# aliases
[[ ! -f "${HOME}/.shell_aliases" ]] || source "${HOME}/.shell_aliases"
# functions
[[ ! -f "${HOME}/.shell_functions" ]] || source "${HOME}/.shell_functions"

# source the `.bashrc` file
function sync() {
	echo "Syncing Bash Configuration..."
	source ~/.bashrc
	echo "Bash Configuration Synced!"
}

##########################################################
###################### OH-MY-BASH ########################
##########################################################

export OSH="${HOME}/.oh-my-bash"

# Oh My Bash Settings
completions=(
	awscli
	brew
	composer
	docker
	git
	gh
	makefile
	ssh
	uv
)
aliases=(
	general
)
plugins=(
	starship
	git
	bashmarks
	zoxide
)
if command -v fzf &>/dev/null; then
	plugins+=("fzf")
fi

source "${OSH}/oh-my-bash.sh"

##########################################################
##################### SHELL HISTORY ######################
##########################################################

HISTFILE=${HOME}/.bash_history
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"
HISTCONTROL=ignoredups:erasedups:ignorespace
HISTTIMEFORMAT='%F %T '

##########################################################
############### APP SPECIFIC CONFIGS #####################
##########################################################

# thefuck
if command -v thefuck &>/dev/null; then
	eval "$(thefuck --alias)"
	eval "$(thefuck --alias dang)"
fi
# direnv
if command -v direnv &>/dev/null; then
	eval "$(direnv hook bash)"
fi

#########################################################################################################

# Amazon Q
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash" ]]; then
	builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash"
fi
# Fig Ignore
