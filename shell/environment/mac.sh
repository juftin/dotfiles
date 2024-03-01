##########################################################
###################### mac setup #########################
##########################################################

[[ ! -f ${HOME}/.dotfiles/shell/aliases.sh ]] || source ${HOME}/.dotfiles/shell/aliases.sh

log_event "info" "Setting up environment for macOS"

###############
# Xcode
###############
if ! command -v xcode-select &>/dev/null; then
	echo "Xcode command line tools not found. Do you want to install Xcode command line tools? [y/n]"
	read -r install_xcode_response
	if [[ $install_xcode_response == "y" ]]; then
		log_event "warning" "Installing Xcode command line tools"
		xcode-select --install
		log_event "info" "Xcode command line tools installed"
	else
		log_event "warning" "Skipping Xcode command line tools installation."
	fi
else
	log_event "info" "Xcode command line tools found"
fi

###############
# homebrew
###############
if ! command -v brew &>/dev/null; then
	echo "Homebrew not found. Do you want to install Homebrew? [y/n]"
	read -r install_brew_response
	if [[ $install_brew_response == "y" ]]; then
		log_event "warning" "Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		log_event "info" "Homebrew installed"
	else
		log_event "warning" "Skipping Homebrew installation."
	fi
else
	log_event "info" "Homebrew found"
fi

###############
# jq
###############
if ! command -v jq &>/dev/null; then
	echo "jq not found. Do you want to install jq? [y/n]"
	read -r install_jq_response
	if [[ $install_jq_response == "y" ]]; then
		log_event "warning" "Installing jq"
		brew install jq
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
		log_event "warning" "Installing autojump"
		brew install autojump
		log_event "info" "autojump installed"
	else
		log_event "warning" "Skipping autojump installation."
	fi
else
	log_event "info" "autojump found"
fi
