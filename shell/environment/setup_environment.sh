##########################################################
################## environment setup #####################
##########################################################

if [[ $OSTYPE == "linux-gnu" ]]; then
	export OS="linux"
elif [[ $OSTYPE == "darwin"* ]]; then
	export OS="mac"
else
	echo "OS not supported"
	exit 1
fi

if [[ $OS == "mac" ]]; then
	source "${HOME}/.dotfiles/shell/environment/mac.sh"
elif [[ $OS == "linux" ]]; then
	source "${HOME}/.dotfiles/shell/environment/linux.sh"
fi
