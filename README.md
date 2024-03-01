# dot-files

This repository contains my personal dot-files.

```shell
git clone https://github.com/juftin/dotfiles.git ~/.dotfiles
```

### `~/.zshrc`

```shell
##########################################################
################# DOTFILE INSTALLATION ###################
##########################################################

DOTFILE_REPO="juftin/dotfiles"

if [[ ! -d ${HOME}/.dotfiles ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}~/.dotfiles%F{220} from GitHub…%f"
    command git clone https://github.com/${DOTFILE_REPO} "${HOME}/.dotfiles" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

[[ ! -f ${HOME}/.dotfiles/dotfiles.zsh ]] || source ${HOME}/.dotfiles/dotfiles.zsh

##########################################################
```
