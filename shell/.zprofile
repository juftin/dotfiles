# CodeWhisperer pre block. Keep at the top of this file.
if [[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]]; then
  builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"
fi

if [[ ! $PATH == *"${HOME}/.local/bin"* && -d "${HOME}/.local/bin" ]]; then
	export PATH="$PATH:${HOME}/.local/bin"
fi

if [[ $(uname -m) == "arm64" && -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ $(uname -m) == "x86_64" && -d /usr/local ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if [[ -d ${HOME}/.pyenv && -z ${PYENV_ROOT} ]]; then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  eval "$(pyenv init -)"
  export PIPX_DEFAULT_PYTHON=$(pyenv which python) #  pipx
  alias awsume="source \$(pyenv which awsume)"
fi

# CodeWhisperer post block. Keep at the bottom of this file.
if [[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]]; then
  builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
fi
# Fig Ignore
