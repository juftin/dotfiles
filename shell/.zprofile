# Amazon Q
if [[ -z "${_AMAZON_Q_INITIALIZED_ZPROFILE_PRE}" ]]; then
    if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]]; then
      builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
    fi
    export _AMAZON_Q_INITIALIZED_ZPROFILE_PRE="1"
fi

# shell-startup
[[ ! -f "${HOME}/.shell_startup" ]] || source "${HOME}/.shell_startup"
[[ ! -f "${HOME}/.shell_vars" ]] || source "${HOME}/.shell_vars"

# Amazon Q
if [[ -z "${_AMAZON_Q_INITIALIZED_ZPROFILE_POST}" ]]; then
    if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]]; then
      builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
    fi
    export _AMAZON_Q_INITIALIZED_ZPROFILE_POST="1"
fi
# Fig Ignore
