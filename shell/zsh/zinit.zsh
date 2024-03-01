##########################################################
####################### zinit init #######################
##########################################################

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node
### End of Zinit's installer chunk

##########################################################
################### zinit - plugins ######################
##########################################################

setopt promptsubst  # Enable prompt substitution

# oh-my-zsh plugins
zinit wait lucid for \
    OMZP::git \
    OMZP::dotenv \
    OMZP::asdf \
    OMZP::web-search \
    OMZP::nvm

[[ -x $(command -v autojump) ]] && zinit wait lucid for OMZP::autojump

# oh-my-zsh theme
zinit ice depth"1"  # git clone depth
zinit light romkatv/powerlevel10k
[[ ! -f ${HOME}/.dotfiles/shell/zsh/.p10k.zsh ]] || source ${HOME}/.dotfiles/shell/zsh/.p10k.zsh

# third party plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

#########################################################
#########################################################
