#########################################################################################################

# shell-startup
[[ ! -f "${HOME}/.shell_startup" ]] || source "${HOME}/.shell_startup"

##########################################################
################# STARSHIP + OH-MY-ZSH ###################
##########################################################

# oh-my-zsh
ZSH="${HOME}/.oh-my-zsh"

plugins=(
    starship
    aws
    git
    docker
    asdf
    web-search
    z
    fast-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)

if ! command -v omz &> /dev/null; then
    source "${ZSH}/oh-my-zsh.sh"
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

# variables
[[ ! -f "${HOME}/.shell_vars" ]] || source "${HOME}/.shell_vars"
[[ ! -f "${HOME}/.zshenv" ]] || source "${HOME}/.zshenv"
# aliases
[[ ! -f "${HOME}/.shell_aliases" ]] || source "${HOME}/.shell_aliases"
# functions
[[ ! -f "${HOME}/.shell_functions" ]] || source "${HOME}/.shell_functions"

# source the `.zshrc` file
function sync() {
	log_event info "Syncing ZSH Configuration..."
	source ~/.zshrc
	log_event info "ZSH Synced!"
}

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
    eval "$(direnv hook zsh)"
fi

# disable autocd
unsetopt autocd

#########################################################################################################

# Fig Ignore
