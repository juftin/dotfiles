##########################################################
###################### ZSH THEME #########################
##########################################################

# Powerlevel10k theme
autoload -Uz promptinit && promptinit && prompt powerlevel10k
[[ ! -f ${DOTFILES_DIR}/shell/zsh/.p10k.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/.p10k.zsh
