##########################################################
#################### juftin/dotfiles #####################
##########################################################

export DOTFILES_DIR="${0:a:h}"

# Shell Settings
[[ ! -f ${DOTFILES_DIR}/shell/settings.sh ]] || source ${DOTFILES_DIR}/shell/settings.sh
# Global Shell Aliases
[[ ! -f ${DOTFILES_DIR}/shell/aliases.sh ]] || source ${DOTFILES_DIR}/shell/aliases.sh
# Load antidote
[[ ! -f ${DOTFILES_DIR}/shell/zsh/antidote.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/antidote.zsh
# ZSH Settings
[[ ! -f ${DOTFILES_DIR}/shell/zsh/settings.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/settings.zsh
# Shell History
[[ ! -f ${DOTFILES_DIR}/shell/zsh/history.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/history.zsh
