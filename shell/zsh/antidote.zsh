##########################################################
######################## antidote ########################
##########################################################

if [[ ! -d ${HOME}/.antidote ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}Antidote%F{220} from GitHub…%f"
    command git clone --depth=1 https://github.com/mattmc3/antidote.git ${HOME}/.antidote && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Set the name of the static .zsh plugins file antidote will generate.
zsh_plugins=${HOME}/.dotfiles/shell/zsh/.zsh_plugins.zsh
# Ensure you have a .zsh_plugins.txt file where you can add plugins.
[[ -f ${zsh_plugins:r}.txt ]] || touch ${zsh_plugins:r}.txt

# Lazy-load antidote.
fpath+=(${HOME}/.antidote)
autoload -Uz $fpath[-1]/antidote

# Generate static file in a subshell when .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins} -nt ${zsh_plugins:r}.txt ]]; then
  (antidote bundle <${zsh_plugins:r}.txt >|${zsh_plugins})
fi

# compinit
autoload -Uz compinit
compinit

# Source the static plugins file.
source ${zsh_plugins}

# Powerlevel10k theme
autoload -Uz promptinit && promptinit && prompt powerlevel10k
[[ ! -f ${HOME}/.dotfiles/shell/zsh/.p10k.zsh ]] || source ${HOME}/.dotfiles/shell/zsh/.p10k.zsh
