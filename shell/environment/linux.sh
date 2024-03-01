##########################################################
##################### Linux setup ########################
##########################################################

[[ ! -f ${HOME}/.dotfiles/shell/aliases.sh ]] || source ${HOME}/.dotfiles/shell/aliases.sh

log_event "info" "Setting up environment for Linux"

detect_package_manager() {
	if command -v apt &>/dev/null; then
		command -v apt update &>/dev/null
		echo "apt"
	elif command -v yum &>/dev/null; then
		command -v yum check-update &>/dev/null
		echo "yum"
	elif command -v pacman &>/dev/null; then
		command -v pacman -Sy &>/dev/null
		echo "pacman"
	else
		log_event "error" "No known package manager found. You may need to install software manually."
		exit 1
	fi
}

###############
# jq
###############
if ! command -v jq &>/dev/null; then
	echo "jq not found. Do you want to install jq? [y/n]"
	read -r install_jq_response
	if [[ $install_jq_response == "y" ]]; then
		pkg_manager=$(detect_package_manager)
		log_event "info" "Package manager detected: ${pkg_manager}"
		log_event "warning" "Installing jq"
		$pkg_manager install -y jq
		log_event "info" "jq installed"
	else
		log_event "warning" "Skipping jq installation."
	fi
else
	log_event "info" "jq found"
fi

###############
# autojump
###############
if ! command -v autojump &>/dev/null; then
	echo "autojump not found. Do you want to install autojump? [y/n]"
	read -r install_autojump_response
	if [[ $install_autojump_response == "y" ]]; then
		pkg_manager=$(detect_package_manager)
		log_event "info" "Package manager detected: ${pkg_manager}"
		log_event "warning" "Installing autojump"
		$pkg_manager install -y autojump
		log_event "info" "autojump installed"
	else
		log_event "warning" "Skipping autojump installation."
	fi
else
	log_event "info" "autojump found"
fi
