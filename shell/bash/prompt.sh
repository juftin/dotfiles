export OSH="${HOME}/.oh-my-bash"

if [[ ! -d ${HOME}/.oh-my-bash ]]; then
	install_from_github "ohmybash/oh-my-bash" "${OSH}"
fi

# Oh My Bash Settings
OSH_THEME="powerline-multiline"
OMB_PROMPT_SHOW_PYTHON_VENV=true

completions=(
	git
	composer
	ssh
)

aliases=(
	general
)

plugins=(
	git
)

source "${OSH}/oh-my-bash.sh"
