##########################################################
############# juftin/dotfiles installation ###############
##########################################################

set -e

function log_event() {
	NO_COLOR='\033[0m'
	BLUE='\033[0;34m'
	GREEN='\033[0;32m'
	RED='\033[0;31m'
	ORANGE='\033[0;33m'
	PURPLE='\033[0;35m'

	LOGGING_TIMESTAMP="${BLUE}$(date +"%F %T,000")${NO_COLOR}"

	case "${1}" in
	"info")
		echo -e "${LOGGING_TIMESTAMP} ${GREEN}INFO: ${NO_COLOR}${2}"
		;;
	"error")
		echo -e "${LOGGING_TIMESTAMP} ${RED}ERROR: ${NO_COLOR}${2}"
		;;
	"warning")
		echo -e "${LOGGING_TIMESTAMP} ${ORANGE}WARNING: ${NO_COLOR}${2}"
		;;
	*)
		echo -e "${LOGGING_TIMESTAMP} ${PURPLE}${1}: ${NO_COLOR}${2}"
		;;
	esac
}

if [[ $OSTYPE == "linux-gnu" ]]; then
	log_event "info" "Linux environment detected, setting up environment"
	export OS="linux"
elif [[ $OSTYPE == "darwin"* ]]; then
	log_event "info" "Mac environment detected, setting up environment"
	export OS="mac"
else
	log_event "error" "OS not supported, exiting"
	exit 1
fi

PACKAGES_TO_INSTALL=(
	"git"
	"curl"
	"zsh"
	"grep"
)

install_packges() {
	if command -v brew &>/dev/null; then
		log_event "info" "Homebrew detected, installing dependencies"
		brew update &>/dev/null
		brew install "${PACKAGES_TO_INSTALL[@]}"
	elif command -v apt &>/dev/null; then
		log_event "info" "apt detected, installing dependencies"
		apt update &>/dev/null
		apt install "${PACKAGES_TO_INSTALL[@]}"
	elif command -v yum &>/dev/null; then
		log_event "info" "yum detected, installing dependencies"
		command -v yum check-update &>/dev/null
		yum install "${PACKAGES_TO_INSTALL[@]}"
	elif command -v pacman &>/dev/null; then
		log_event "info" "pacman detected, installing dependencies"
		command -v pacman -Sy &>/dev/null
		pacman -S "${PACKAGES_TO_INSTALL[@]}"
	else
		log_event "error" "No known package manager found. You may need to install software manually."
		exit 1
	fi
}

if [[ ! -f "${HOME}/.zshrc" ]]; then
	touch "${HOME}/.zshrc"
fi

if ! grep -q ".dotfiles" "${HOME}/.zshrc"; then
	log_event "warning" ".dotfiles not mentioned in .zshrc, adding it"
	cat <<EOF >>"${HOME}/.zshrc"
##########################################################
################# DOTFILE INSTALLATION ###################
##########################################################

DOTFILE_REPO="juftin/dotfiles"

if [[ ! -d ${HOME}/.dotfiles ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}~/.dotfiles%F{220} from GitHub…%f"
    command git clone https://github.com/${DOTFILE_REPO} "${HOME}/.dotfiles" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

[[ ! -f ${HOME}/.dotfiles/dotfiles.zsh ]] || source ${HOME}/.dotfiles/dotfiles.zsh

##########################################################
EOF
else
	log_event "info" "dotfiles mentioned in .zshrc"
fi

install_packges

log_event "info" "Installation complete, please restart your shell to apply changes"
