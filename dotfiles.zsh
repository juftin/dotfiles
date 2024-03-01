##########################################################
#################### juftin/dotfiles #####################
##########################################################

DOTFILES_DIR="${0:a:h}"

# Load zinit
[[ ! -f ${DOTFILES_DIR}/shell/zsh/zinit.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/zinit.zsh
# Shell History
[[ ! -f ${DOTFILES_DIR}/shell/zsh/history.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/history.zsh
# Shell Search
[[ ! -f ${DOTFILES_DIR}/shell/zsh/search.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/search.zsh
# Shell Autocomplete
[[ ! -f ${DOTFILES_DIR}/shell/zsh/autocomplete.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/autocomplete.zsh
# Global Shell Aliases
[[ ! -f ${DOTFILES_DIR}/shell/aliases.zsh ]] || source ${DOTFILES_DIR}/shell/aliases.zsh
