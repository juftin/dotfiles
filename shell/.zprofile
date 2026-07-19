# kiro-cli
if [[ -z "${_KIRO_INITIALIZED_ZPROFILE_PRE}" ]]; then
    if [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]]; then
      builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"
    fi
    export _KIRO_INITIALIZED_ZPROFILE_PRE="1"
fi

# shell-startup
[[ ! -f "${HOME}/.shell_startup" ]] || source "${HOME}/.shell_startup"
[[ ! -f "${HOME}/.shell_vars" ]] || source "${HOME}/.shell_vars"

# orbstack
if [[ -f "${HOME}/.orbstack/shell/init.zsh" && -z "${_ORBSTACK_INIT}" ]]; then
    source "${HOME}/.orbstack/shell/init.zsh"
    export _ORBSTACK_INIT=1
fi

# kiro-cli
if [[ -z "${_KIRO_INITIALIZED_ZPROFILE_POST}" ]]; then
    if [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]]; then
      builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"
    fi
    export _KIRO_INITIALIZED_ZPROFILE_POST="1"
fi
# Fig Ignore
