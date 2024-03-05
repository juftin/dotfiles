#!/usr/bin/env bash

set -e

##########################################################
############# juftin/dotfiles bootstrapping ##############
##########################################################

DOTFILES_REPO="${DOTFILES_REPO:-juftin/dotfiles}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-""}"
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"

if [[ $- == *i* ]]; then
	INTERACTIVE_SHELL=true
else
	INTERACTIVE_SHELL=false
fi

##########################################################
####################### ascii art ########################
##########################################################

# ANSI Color Codes
NO_COLOR='\033[0m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'

# ASCII Art
DOTFILES_ASCII_TEXT=$(
	cat <<EOF

${RED}   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗${NO_COLOR}
${ORANGE}   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝${NO_COLOR}
${YELLOW}   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗${NO_COLOR}
${GREEN}   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║${NO_COLOR}
${BLUE}██╗██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║${NO_COLOR}
${PURPLE}╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝${NO_COLOR}

EOF
)

# print the .dotfiles ASCII Art
function dotfiles_ascii() {
	echo -e "${DOTFILES_ASCII_TEXT}"
	echo ""
	log_event "info" "Bootstrapping ${PURPLE}${DOTFILES_REPO}${NO_COLOR} 🚀"
}

##########################################################
############ bootstrapping common functions ##############
##########################################################

###########################
# Clone From GitHub
###########################
function install_from_github() {
	local repo=$1
	local target=$2
	local branch=${3:-""}
	if [[ ! -d ${target} ]]; then
		if [[ -n ${branch} ]]; then
			log_event "info" "Cloning ${PURPLE}${repo}${NO_COLOR} (${ORANGE}${branch}${NO_COLOR}) from GitHub: ${GREEN}${target}${NO_COLOR} 🗂️"
			git clone -q --depth=1 --branch=${branch} https://github.com/${repo}.git ${target} &&
				log_event "info" "Installation of ${PURPLE}${repo}${NO_COLOR} successful 📪" ||
				log_event "error" "Installation of ${PURPLE}${repo}${NO_COLOR} failed 🚫"
		else
			log_event "info" "Cloning ${PURPLE}${repo}${NO_COLOR} from GitHub: ${GREEN}${target}${NO_COLOR} 🗂️"
			git clone -q --depth=1 https://github.com/${repo}.git ${target} &&
				log_event "info" "Installation of ${PURPLE}${repo}${NO_COLOR} successful 📪" ||
				log_event "error" "Installation of ${PURPLE}${repo}${NO_COLOR} failed 🚫"
		fi
	fi
}

###########################
# Install ~/.dotfiles
###########################
function install_dotfiles() {
	if [[ ! -d ${DOTFILES_DIR} ]]; then
		install_from_github "${DOTFILES_REPO}" "${DOTFILES_DIR}" "${DOTFILES_BRANCH}"
	else
		log_event "warning" "${PURPLE}${DOTFILES_DIR}${NO_COLOR} already exists, ${RED}skipping installation${NO_COLOR} 🚫"
	fi
}

###########################
# Initialize Submodules
###########################
function init_submodules() {
	log_event "info" "Cloning tools from GitHub 🔄"
	git -C "${DOTFILES_DIR}/bootstrap" submodule sync --quiet --recursive &
	spinner
	git -C "${DOTFILES_DIR}" submodule update --init --recursive --depth 1 --jobs 4 &>/dev/null &
	spinner
	log_event "info" "Cloned tools initialized ✅"
}

##########################################################
################ package installing ######################
##########################################################

DEPENDENCIES=(
	git
	curl
	zsh
	autojump
)

function install_dependencies() {
	local package
	local packages_to_install=()

	###########################
	# Determine Package Manager
	###########################
	if command -v brew &>/dev/null; then
		PACKAGE_MANAGER="brew"
	elif command -v apt &>/dev/null; then
		PACKAGE_MANAGER="apt"
	elif command -v yum &>/dev/null; then
		PACKAGE_MANAGER="yum"
		DEPENDENCIES=(
			git
			curl
			zsh
			autojump-zsh
		)
	else
		log_event "error" "No package manager detected"
		exit 1
	fi

	###########################
	# Build packages to install
	###########################
	for package in "${DEPENDENCIES[@]}"; do
		if ! command -v "${package}" &>/dev/null; then
			packages_to_install+=("${package}")
		fi
	done
	if [ ${#packages_to_install[@]} -eq 0 ]; then
		return 0
	fi

	###########################
	# apt update
	###########################
	if [ "${PACKAGE_MANAGER}" == "apt" ]; then
		if [ "${APT_UPDATED:-false}" == "false" ]; then
			log_event "info" "Fetching latest package information from ${BLUE}${PACKAGE_MANAGER}${NO_COLOR} ⬆️"
			apt update &>/dev/null &
			spinner
			APT_UPDATED=true
		fi
	fi

	###########################
	# Install the Dependencies
	###########################
	log_event "info" "Installing ${PURPLE}${packages_to_install[*]}${NO_COLOR} with ${BLUE}${PACKAGE_MANAGER}${NO_COLOR} 📦"
	if [ "${PACKAGE_MANAGER}" == "brew" ]; then
		brew install "${packages_to_install[@]}" &>/dev/null &
		spinner || log_event "error" "Failed to install ${PURPLE}${packages_to_install[@]}${NO_COLOR} with ${BLUE}${PACKAGE_MANAGER}${NO_COLOR}"
	elif [ "${PACKAGE_MANAGER}" == "apt" ]; then
		apt install -y "${packages_to_install[@]}" &>/dev/null &
		spinner || log_event "error" "Failed to install ${PURPLE}${packages_to_install[@]}${NO_COLOR} with ${BLUE}${PACKAGE_MANAGER}${NO_COLOR}"
	elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
		yum install -y "${packages_to_install[@]}" &>/dev/null &
		spinner || log_event "error" "Failed to install ${PURPLE}${packages_to_install[@]}${NO_COLOR} with ${BLUE}${PACKAGE_MANAGER}${NO_COLOR}"
	fi
}

##########################################################
####################### logging ##########################
##########################################################

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

function spinner() {
	local pid=$!
	local delay=0.1
	local spinstr='|/-\\'
	tput civis
	while kill -0 $pid 2>/dev/null; do
		local temp=${spinstr#?}
		printf " %c  " "$spinstr"
		spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"
	done
	tput cnorm
	printf "    \b\b\b\b"
}

function log_success() {
	log_event "info" "Enjoy your new ✨ ${PURPLE}.dotfiles${NO_COLOR} ✨"
	log_event "info" "Bootstrapping ${PURPLE}${DOTFILES_REPO}${NO_COLOR} ${GREEN}complete${NO_COLOR} 🎉"
}

##########################################################
##################### symlinking #########################
##########################################################

function symlink_item() {
	local source="${1}"
	local destination="${2}"

	# if the source does not exist, log an error and return
	if [ ! -e "${source}" ]; then
		log_event "error" "Source ${GREEN}${source}${NO_COLOR} does not exist"
		return 1
	fi

	# if the destination exists and is a symlink and the source is the same, return
	if [ -L "${destination}" ] && [ "$(readlink "${destination}")" == "${source}" ]; then
		log_event "info" "Symlink ${BLUE}${destination}${NO_COLOR} already exists, skipping ✅"
		return 0
	elif [ -L "${destination}" ]; then
		log_event "info" "Removing existing symlink ${RED}${destination}${NO_COLOR} 🗑️"
		rm "${destination}"
	fi

	# if the destination exists and is a file or directory
	if [ -e "${destination}" ]; then
		local timestamp=$(date +"%Y%m%d%H%M%S" | cut -c 1-12)
		local backup_destination="${destination}.${timestamp}"
		log_event "warning" "Backing up existing file/directory ${GREEN}${destination}${NO_COLOR} to ${BLUE}${backup_destination}${NO_COLOR} 💾"
		mv "${destination}" "${backup_destination}"
	fi

	# create the symlink
	log_event "info" "Creating symlink ${GREEN}${destination}${NO_COLOR} 🔗"
	ln -s "${source}" "${destination}"
}

##########################################################
###################### symlinks ##########################
##########################################################

function symlink_dotfiles() {
	# Shell Plugins
	symlink_item "${DOTFILES_DIR}/bootstrap/oh-my-zsh" "${HOME}/.oh-my-zsh"
	# OhMyZsh Custom Plugins
	symlink_item "${DOTFILES_DIR}/bootstrap/powerlevel10k" "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
	symlink_item "${DOTFILES_DIR}/bootstrap/fast-syntax-highlighting" "${HOME}/.oh-my-zsh/custom/plugins/fast-syntax-highlighting"
	symlink_item "${DOTFILES_DIR}/bootstrap/zsh-autosuggestions" "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	symlink_item "${DOTFILES_DIR}/bootstrap/zsh-completions" "${HOME}/.oh-my-zsh/custom/plugins/zsh-completions"
	# OhMyBash
	symlink_item "${DOTFILES_DIR}/bootstrap/oh-my-bash" "${HOME}/.oh-my-bash"
	# Shell Files
	symlink_item "${DOTFILES_DIR}/shell/.zshrc" "${HOME}/.zshrc"
	symlink_item "${DOTFILES_DIR}/shell/.bashrc" "${HOME}/.bashrc"
	symlink_item "${DOTFILES_DIR}/shell/.p10k.zsh" "${HOME}/.p10k.zsh"
	symlink_item "${DOTFILES_DIR}/shell/.shell_aliases" "${HOME}/.shell_aliases"
	symlink_item "${DOTFILES_DIR}/shell/.mac_aliases" "${HOME}/.mac_aliases"
}

##########################################################
######################## script ##########################
##########################################################

dotfiles_ascii
install_dependencies
install_dotfiles
init_submodules
symlink_dotfiles
log_success
