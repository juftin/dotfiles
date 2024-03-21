# CodeWhisperer pre block. Keep at the top of this file.
if [[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.bash" ]]; then
  builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.bash"
fi

if [[ -d ${HOME}/.pyenv && -z ${PYENV_ROOT} ]]; then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  eval "$(pyenv init -)"
  alias awsume="source \$(pyenv which awsume)"
fi

if [[ ! $PATH == *"${HOME}/.local/bin"* && -d "${HOME}/.local/bin" ]]; then
	export PATH="$PATH:${HOME}/.local/bin"
fi

# CodeWhisperer post block. Keep at the bottom of this file.
if [[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.bash" ]]; then
  builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.bash"
fi
# Fig Ignore
