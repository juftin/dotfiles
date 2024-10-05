# Amazon Q pre block. Keep at the top of this file.
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]]; then
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#########################################################################################################

##########################################################
##################### ZSH SETTINGS #######################
##########################################################

export EDITOR=nano

_DOTFILES_DIR="$(dirname "$(dirname "$(readlink -f ~/.zshrc)")")"
if [[ ! $PATH == *"${_DOTFILES_DIR}/bin"* ]]; then
    export PATH="$PATH:${_DOTFILES_DIR}/bin"
fi

if [[ ! $PATH == *"${HOME}/.local/bin"* ]]; then
    mkdir -p "${HOME}/.local/bin"
	export PATH="$PATH:${HOME}/.local/bin"
fi

# source the `.zshrc` file
function sync() {
	log_event info "Syncing ZSH Configuration..."
	source ~/.zshrc
	log_event info "ZSH Synced!"
}

##########################################################
####################### OH-MY-ZSH ########################
##########################################################

ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    aws
    git
    docker
    asdf
    web-search
    nvm
    z
    fast-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)

if ! command -v omz &> /dev/null; then
    source "${ZSH}/oh-my-zsh.sh"
fi

if [[ -z ${POWERLEVEL9K_INSTANT_PROMPT} && -f ${HOME}/.p10k.zsh ]]; then
  source ${HOME}/.p10k.zsh
fi

##########################################################
##################### SHELL HISTORY ######################
##########################################################

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt append_history           # Dont overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.
setopt hist_expire_dups_first   # Expire duplicates first when trimming history.
setopt hist_verify              # Don't execute expanded history commands.
setopt inc_append_history       # Add commands to the history file immediately.

##########################################################
############### ENV / ALIASES / FUNCTIONS ################
##########################################################

# Environment Variables
[[ ! -f ${HOME}/.shell_vars ]] || source ${HOME}/.shell_vars
[[ ! -f ${HOME}/.zshenv ]] || source ${HOME}/.zshenv
# Aliases
[[ ! -f ${HOME}/.shell_aliases ]] || source ${HOME}/.shell_aliases
[[ ! -f ${HOME}/.zsh_aliases ]] || source ${HOME}/.zsh_aliases
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

# go
GOBIN="${GOBIN:-${HOME}/go/bin}"
if [[ -d ${GOBIN} && ! $PATH == *"${GOBIN}"* ]]; then
    export PATH="${GOBIN}:${PATH}"
fi

# thefuck
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
    eval "$(thefuck --alias dang)"
fi

if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# disable autocd
unsetopt autocd

#########################################################################################################

# Amazon Q post block. Keep at the bottom of this file.
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]]; then
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
fi
# Fig Ignore
