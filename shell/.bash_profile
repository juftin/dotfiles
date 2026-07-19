# kiro-cli
if [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.pre.bash" ]]; then
	builtin source "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.pre.bash"
fi

# startup
[[ ! -f "${HOME}/.shell_startup" ]] || source "${HOME}/.shell_startup"
# variables
[[ ! -f "${HOME}/.shell_vars" ]] || source "${HOME}/.shell_vars"

# orbstack
if [[ -f "${HOME}/.orbstack/shell/init.bash" && -z ${_ORBSTACK_INIT} ]]; then
	source "${HOME}/.orbstack/shell/init.bash"
	export _ORBSTACK_INIT=1
fi

# kiro-cli
if [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.post.bash" ]]; then
	builtin source "${HOME}/Library/Application Support/kiro-cli/shell/bash_profile.post.bash"
fi
# Fig Ignore
