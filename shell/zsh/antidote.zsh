##########################################################
######################## antidote ########################
##########################################################

if [[ ! -d ${HOME}/.antidote ]]; then
    install_from_github "mattmc3/antidote" "${HOME}/.antidote"
fi

# Set the name of the static .zsh plugins file antidote will generate.
zsh_plugins=${DOTFILES_DIR}/shell/zsh/zsh_plugins.txt
zsh_plugins_compiled=${HOME}/.zsh_plugins.zsh
# Ensure you have a .zsh_plugins.txt file where you can add plugins.
[[ -f ${zsh_plugins} ]] || touch ${zsh_plugins}

# Lazy-load antidote.
fpath+=(${HOME}/.antidote)
autoload -Uz $fpath[-1]/antidote

# Generate static file in a subshell when .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins_compiled} -nt ${zsh_plugins} ]]; then
  (antidote bundle <${zsh_plugins} >|${zsh_plugins_compiled})
fi

# compinit
autoload -Uz compinit
compinit

# Source the static plugins file.
source ${zsh_plugins_compiled}
