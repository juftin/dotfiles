# Amazon Q pre block. Keep at the top of this file.
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash" ]]; then
	builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash"
fi

#########################################################################################################

##########################################################
#################### BASH SETTINGS #######################
##########################################################

export EDITOR=nano

if [[ $PATH != *"${HOME}/.local/bin"* ]]; then
	mkdir -p "${HOME}/.local/bin"
	export PATH="$PATH:${HOME}/.local/bin"
fi

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
OSH_THEME="powerline-multiline"
OMB_PROMPT_SHOW_PYTHON_VENV=true

completions=(
	git
	composer
	ssh
)

aliases=(
	general
)

plugins=(
	git
)

source "${OSH}/oh-my-bash.sh"

# Environment Variables
[[ ! -f ${HOME}/.bashenv ]] || source ${HOME}/.bashenv
# Aliases
[[ ! -f ${HOME}/.shell_aliases ]] || source ${HOME}/.shell_aliases
# Functions
[[ ! -f ${HOME}/.shell_functions ]] || source ${HOME}/.shell_functions

##########################################################
############### APP SPECIFIC CONFIGS #####################
##########################################################

# pyenv
if [[ -d ${HOME}/.pyenv && -z ${PYENV_ROOT} ]]; then
	export PYENV_ROOT="${HOME}/.pyenv"
	export PATH="${PYENV_ROOT}/bin:${PATH}"
	eval "$(pyenv init -)"
	export PIPX_DEFAULT_PYTHON=$(pyenv which python) #  pipx
	alias awsume="source \$(pyenv which awsume)"
fi

# rust
[[ ! -f ${HOME}/.cargo/env ]] || source ${HOME}/.cargo/env

# thefuck
if command -v thefuck &>/dev/null; then
	eval "$(thefuck --alias)"
	eval "$(thefuck --alias dang)"
fi
if command -v direnv &>/dev/null; then
	eval "$(direnv hook bash)"
fi

#########################################################################################################

# Amazon Q post block. Keep at the bottom of this file.
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash" ]]; then
	builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash"
fi
# Fig Ignore
