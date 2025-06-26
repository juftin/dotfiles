# Amazon Q
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]]; then
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
fi

# shell-startup
[[ ! -f "${HOME}/.shell_startup" ]] || source "${HOME}/.shell_startup"
[[ ! -f "${HOME}/.shell_vars" ]] || source "${HOME}/.shell_vars"

# Amazon Q
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]]; then
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
fi
# Fig Ignore
