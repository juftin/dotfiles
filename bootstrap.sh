#!/usr/bin/env bash

set -e

##########################################################
############# juftin/dotfiles bootstrapping ##############
##########################################################

DOTFILES_REPO="${DOTFILES_REPO:-juftin/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"

##########################################################
############ bootstrapping common functions ##############
##########################################################

# ANSI Color Codes
NO_COLOR='\033[0m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m' # Brighter version for better visibility
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

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

# Logging
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

# shallow clone from GitHub
function install_from_github() {
	local repo=$1
	local target=$2
	if [[ ! -d ${target} ]]; then
		log_event "info" "Cloning ${PURPLE}${repo}${NO_COLOR} from GitHub: ${GREEN}${repo}${NO_COLOR} 🗂️"
		git clone -q --depth=1 https://github.com/${repo}.git ${target} &&
			log_event "info" "Installation of ${PURPLE}${repo}${NO_COLOR} successful 📪" ||
			log_event "error" "Installation of ${PURPLE}${repo}${NO_COLOR} failed 🚫"
	fi
}

# install the .dotfiles repository
function install_dotfiles() {
	if [[ ! -d {DOTFILES_DIR} ]]; then
		install_from_github "${DOTFILES_REPO}" "${DOTFILES_DIR}"
	fi
	# Check if the shell configuration files exist and create them if not
	[[ -f "${HOME}/.zshrc" ]] || touch "${HOME}/.zshrc"
	[[ -f "${HOME}/.bashrc" ]] || touch "${HOME}/.bashrc"
}

# install an executable if it is not found
function log_installation() {
	if ! command -v ${1} &>/dev/null; then
		log_event "info" "Executable ${BLUE}${1}${NO_COLOR} not found, ${GREEN}installing${NO_COLOR} 📦"
		eval ${2} ${1} &>/dev/null
	else
		log_event "info" "Executable ${BLUE}${1}${NO_COLOR} already installed, ${RED}skipping${NO_COLOR} 🚫"
	fi
}

# base dependencies
PACKAGES_TO_INSTALL=(
	"git"
	"curl"
	"zsh"
	"grep"
	"jq"
	"autojump"
)

# install base dependencies
function install_packages() {

	local pkg_manager=""
	local install_cmd=""
	local update_cmd=""

	# Determine the package manager and prepare commands
	if command -v brew &>/dev/null; then
		pkg_manager="brew"
		install_cmd="brew install"
		update_cmd="brew update"
	elif command -v apt &>/dev/null; then
		pkg_manager="apt"
		install_cmd="apt install -y"
		update_cmd="apt update"
	elif command -v yum &>/dev/null; then
		pkg_manager="yum"
		install_cmd="yum install -y"
		update_cmd=":"
		PACKAGES_TO_INSTALL=(
			"git"
			"curl"
			"zsh"
			"grep"
			"jq"
			"autojump-zsh"
		)
	else
		log_event "warning" "${RED}No known package manager found. You may need to install software manually.${NO_COLOR} ⚠️"
		return
	fi

	log_event "info" "${ORANGE}${pkg_manager}${NO_COLOR} detected, preparing to install dependencies 🛠"
	log_event "info" "Fetching the latest package information from ${ORANGE}${pkg_manager}${NO_COLOR} ⬆️"
	eval ${update_cmd} &>/dev/null

	for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
		log_installation "${pkg}" "${install_cmd}"
	done
}

# bootstrap the .zshrc file
function bootstrap_zshrc() {
	# If ".dotfiles" is not mentioned in shell config, add it
	if ! grep -q ".dotfiles" "${HOME}/.zshrc"; then
		log_event "warning" "${PURPLE}.dotfiles${NO_COLOR} not mentioned in ${PURPLE}~/.zshrc${NO_COLOR}, adding it ✍️"
		# Add .dotfiles to shell config
		cat <<'EOF' >>"${HOME}/.zshrc"

######################################################################################
############################### DOTFILE INSTALLATION #################################
######################################################################################

[[ ! -f ${HOME}/.dotfiles/dotfiles.zsh ]] || source ${HOME}/.dotfiles/dotfiles.zsh

######################################################################################
EOF
	else
		log_event "info" "${PURPLE}.dotfiles${NO_COLOR} already mentioned in ${PURPLE}.zshrc${NO_COLOR}, ${RED}skipping${NO_COLOR} 🚫"
	fi
}

# bootstrap the .bashrc file
function bootstrap_bashrc() {
	# If ".dotfiles" is not mentioned in shell config, add it
	if ! grep -q ".dotfiles" "${HOME}/.bashrc"; then
		log_event "warning" "${PURPLE}.dotfiles${NO_COLOR} not mentioned in ${PURPLE}~/.bashrc${NO_COLOR}, adding it ✍️"
		# Add .dotfiles to shell config
		cat <<'EOF' >>"${HOME}/.bashrc"

######################################################################################
############################### DOTFILE INSTALLATION #################################
######################################################################################

[[ ! -f ${HOME}/.dotfiles/dotfiles.bash ]] || source ${HOME}/.dotfiles/dotfiles.bash

######################################################################################
EOF
	else
		log_event "info" "${PURPLE}.dotfiles${NO_COLOR} already mentioned in ${PURPLE}.bashrc${NO_COLOR}, ${RED}skipping${NO_COLOR} 🚫"
	fi
}

# start the zsh shell
function start_zsh() {
	if [[ ${SHELL} != "/bin/zsh" ]]; then
		log_event "warning" "${BLUE}zsh${NO_COLOR} is not the current shell, starting a new ${BLUE}zsh${NO_COLOR} shell ⚠️"
		log_event "info" "${BLUE}dotfiles${NO_COLOR} installation ${GREEN}complete${NO_COLOR} ✅"
		log_event "info" "Your ZSH plugins will be installed momentarily 🚀"
		log_event "info" "Enjoy your new ✨ ${PURPLE}.dotfiles${NO_COLOR} ✨"
		exec zsh -l
	else
		log_event "warning" "You may need to re-source your ${PURPLE}.zshrc${NO_COLOR} file to see changes ⚠️"
		log_event "info" "${PURPLE}.dotfiles${NO_COLOR} installation ${GREEN}complete${NO_COLOR} ✅"
		log_event "info" "Your ZSH plugins will be installed automatically on the next shell start 🚀"
		log_event "info" "Enjoy your new ✨ ${PURPLE}.dotfiles${NO_COLOR} ✨"
	fi
}

##########################################################
################ bootstrapping scripts ###################
##########################################################

# print the bootstrap intro
dotfiles_ascii
# install base dependencies
install_packages
# install the ~/.dotfiles directory
install_dotfiles
# bootstrap the ~/.zshrc file
bootstrap_zshrc
# bootstrap the ~/.bashrc file
bootstrap_bashrc
# initialize zsh
start_zsh
