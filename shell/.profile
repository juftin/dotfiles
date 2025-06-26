# Amazon Q
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/profile.pre.bash" ]]; then
	builtin source "${HOME}/Library/Application Support/amazon-q/shell/profile.pre.bash"
fi

# startup
[[ ! -f "${HOME}/.shell_startup" ]] || source "${HOME}/.shell_startup"
# variables
[[ ! -f "${HOME}/.shell_vars" ]] || source "${HOME}/.shell_vars"

# Amazon Q
if [[ -f "${HOME}/Library/Application Support/amazon-q/shell/profile.post.bash" ]]; then
	source "${HOME}/Library/Application Support/amazon-q/shell/profile.post.bash"
fi
# Fig Ignore
