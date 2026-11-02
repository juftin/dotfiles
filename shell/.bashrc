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
	fzf
)

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
# mise
if command -v mise &>/dev/null; then
	eval "$(mise activate bash)"
fi
# orbstack
if [[ -f "${HOME}/.orbstack/shell/init.bash" && -z ${_ORBSTACK_INIT} ]]; then
	source "${HOME}/.orbstack/shell/init.bash"
	export _ORBSTACK_INIT=1
fi
# inshellisense
if [[ -f "${HOME}/.local/share/inshellisense/init/zsh/init.zsh" && -z ${_INSHELLISENSE_INIT} ]]; then
	source "${HOME}/.local/share/inshellisense/init/zsh/init.zsh"
	export _INSHELLISENSE_INIT=1
fi
