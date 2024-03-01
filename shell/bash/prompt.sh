if [[ ! -d ${HOME}/.liquidprompt ]]; then
	install_from_github "nojhan/liquidprompt" "${HOME}/.liquidprompt"
fi

[[ -f ${HOME}/.liquidprompt/themes/powerline/powerline.theme ]] && source ${HOME}/.liquidprompt/themes/powerline/powerline.theme
[[ -f ${HOME}/.liquidprompt/liquidprompt ]] && source ${HOME}/.liquidprompt/liquidprompt

lp_theme powerline
