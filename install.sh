#!/usr/bin/env bash

##########################################################
############# juftin/dotfiles installation ###############
##########################################################

set -e

NO_COLOR='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'

function log_event() {
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
	"jq"
	"autojump"
)

install_packges() {
	if command -v brew &>/dev/null; then
		log_event "info" "${ORANGE}Homebrew${NO_COLOR} detected, preparing to install dependencies..."
		brew update &>/dev/null
		for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
			if ! command -v ${pkg} &>/dev/null; then
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} not found, ${GREEN}installing${NO_COLOR}"
				brew install ${pkg} &>/dev/null
			else
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} already installed, ${RED}skipping${NO_COLOR}"
			fi
		done
	elif command -v apt &>/dev/null; then
		log_event "info" "${ORANGE}apt${NO_COLOR} detected, preparing to install dependencies..."
		apt update &>/dev/null
		for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
			if ! command -v ${pkg} &>/dev/null; then
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} not found, ${GREEN}installing${NO_COLOR}"
				apt install -y ${pkg} &>/dev/null
			else
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} already installed, ${RED}skipping${NO_COLOR}"
			fi
		done
	elif command -v yum &>/dev/null; then
		log_event "info" "${ORANGE}yum${NO_COLOR} detected, preparing to install dependencies..."
		command -v yum check-update &>/dev/null
		for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
			if ! command -v ${pkg} &>/dev/null; then
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} not found, ${GREEN}installing${NO_COLOR}"
				yum install -y ${pkg} &>/dev/null
			else
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} already installed, ${RED}skipping${NO_COLOR}"
			fi
		done
	elif command -v pacman &>/dev/null; then
		log_event "info" "${ORANGE}pacman${NO_COLOR} detected, preparing to install dependencies..."
		command -v pacman -Sy &>/dev/null
		for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
			if ! command -v ${pkg} &>/dev/null; then
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} not found, ${GREEN}installing${NO_COLOR}"
				pacman -S --noconfirm ${pkg} &>/dev/null
			else
				log_event "info" "Package ${BLUE}${pkg}${NO_COLOR} already installed, ${RED}skipping${NO_COLOR}"
			fi
		done
	else
		log_event "error" "No known package manager found. You may need to install software manually."
		exit 1
	fi
}

if [[ ! -f "${HOME}/.zshrc" ]]; then
	touch "${HOME}/.zshrc"
fi

if ! grep -q ".dotfiles" "${HOME}/.zshrc"; then
	log_event "warning" "${PURPLE}.dotfiles${NO_COLOR} not mentioned in ${PURPLE}.zshrc${NO_COLOR}, adding it"
	cat <<EOF >>"${HOME}/.zshrc"
##########################################################
################# DOTFILE INSTALLATION ###################
##########################################################

DOTFILE_REPO="juftin/dotfiles"

if [[ ! -d ${HOME}/.dotfiles ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}~/.dotfiles%F{220} from GitHub…%f"
    command git clone https://github.com/${DOTFILE_REPO} "${HOME}/.dotfiles" && \\
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \\
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

[[ ! -f ${HOME}/.dotfiles/dotfiles.zsh ]] || source ${HOME}/.dotfiles/dotfiles.zsh

##########################################################
EOF
else
	log_event "info" "${PURPLE}.dotfiles${NO_COLOR} already mentioned in ${PURPLE}.zshrc${NO_COLOR}, ${RED}skipping${NO_COLOR}"
fi

install_packges

if [[ ${SHELL} != "/bin/zsh" ]]; then
	log_event "info" "${BLUE}zsh${NO_COLOR} is not the current shell, starting a new zsh shell..."
	log_event "info" "${BLUE}dotfiles${NO_COLOR} installation ${GREEN}complete${NO_COLOR}..."
	exec zsh -l
else
	log_event "warning" "You may need to re-source your ${PURPLE}.zshrc${NO_COLOR} file to see changes..."
	log_event "info" "${BLUE}dotfiles${NO_COLOR} installation ${GREEN}complete${NO_COLOR}..."
fi
