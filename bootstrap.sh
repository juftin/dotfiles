#!/usr/bin/env bash

set -e

##########################################################
############# juftin/dotfiles bootstrapping ##############
##########################################################

DOTFILES_REPO="${DOTFILES_REPO:-juftin/dotfiles}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-""}"
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"
DOTFILES_DIRNAME=$(basename "${DOTFILES_DIR}")
BOOTSTRAP_SHELL="${BOOTSTRAP_SHELL:-zsh}"
DEFAULT_SHELL="${DEFAULT_SHELL:-zsh}"
CURRENT_SHELL=$(basename "${0}")

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
	log_event "info" "Bootstrap shell: ${GREEN}${BOOTSTRAP_SHELL}${NO_COLOR} 🐚"
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

# install the .dotfiles repository
function install_dotfiles() {
	if [[ ! -d ${DOTFILES_DIR} ]]; then
		install_from_github "${DOTFILES_REPO}" "${DOTFILES_DIR}" "${DOTFILES_BRANCH}"
	else
		log_event "warning" "${PURPLE}${DOTFILES_DIR}${NO_COLOR} already exists, ${RED}skipping installation${NO_COLOR} 🚫"
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
	"grep"
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
		update_cmd=""
	elif command -v apt &>/dev/null; then
		pkg_manager="apt"
		install_cmd="apt install -y"
		update_cmd="apt update"
	elif command -v yum &>/dev/null; then
		pkg_manager="yum"
		install_cmd="yum install -y"
		update_cmd=""
		PACKAGES_TO_INSTALL=(
			"git"
			"curl"
			"grep"
			"jq"
			"autojump-zsh"
		)
	else
		log_event "warning" "${RED}No known package manager found. You may need to install software manually.${NO_COLOR} ⚠️"
		return
	fi

	log_event "info" "${ORANGE}${pkg_manager}${NO_COLOR} detected, preparing to install dependencies 🛠"
	if [[ -n ${update_cmd} ]]; then
		log_event "info" "Fetching the latest package information from ${ORANGE}${pkg_manager}${NO_COLOR} ⬆️"
		eval ${update_cmd} &>/dev/null
	fi
	if [[ ${BOOTSTRAP_SHELL} == "zsh" ]]; then
		PACKAGES_TO_INSTALL+=("zsh")
	fi
	for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
		log_installation "${pkg}" "${install_cmd}"
	done
}

# bootstrap the shell configuration file based on the BOOTSTRAP_SHELL env variable
function bootstrap_shell_config() {
	local shell_config_file

	# Determine which shell configuration file to use
	if [[ ${BOOTSTRAP_SHELL} == "zsh" ]]; then
		shell_config_file="${HOME}/.zshrc"
	elif [[ ${BOOTSTRAP_SHELL} == "bash" ]]; then
		shell_config_file="${HOME}/.bashrc"
	else
		echo "BOOTSTRAP_SHELL is set to an unsupported value: ${BOOTSTRAP_SHELL}. Please set it to either 'zsh' or 'bash'."
		return 1
	fi

	# Check if "${DOTFILES_DIRNAME}" is mentioned in the shell config, and add it if not
	if ! grep -q "${DOTFILES_DIRNAME}" "${shell_config_file}"; then
		log_event "warning" "${PURPLE}${DOTFILES_DIRNAME}${NO_COLOR} not mentioned in ${PURPLE}${shell_config_file}${NO_COLOR}, adding it ✍️"
		# Add .dotfiles to shell config
		cat <<EOF >>"${shell_config_file}"

######################################################################################
############################### DOTFILE INSTALLATION #################################
######################################################################################

[[ ! -f ${DOTFILES_DIR}/dotfiles.${BOOTSTRAP_SHELL} ]] || source ${DOTFILES_DIR}/dotfiles.${BOOTSTRAP_SHELL}

######################################################################################
EOF
	else
		log_event "info" "${PURPLE}${DOTFILES_DIRNAME}${NO_COLOR} already mentioned in ${PURPLE}${shell_config_file}${NO_COLOR}, ${RED}skipping${NO_COLOR} 🚫"
	fi
}

# start the preferred shell
function start_preferred_shell() {
	if [[ ${BOOTSTRAP_SHELL} != "zsh" ]] && [[ ${BOOTSTRAP_SHELL} != "bash" ]]; then
		echo "BOOTSTRAP_SHELL is set to an unsupported value: ${BOOTSTRAP_SHELL}. Please set it to either 'zsh' or 'bash'."
		return 1
	fi
	if [[ ${CURRENT_SHELL} == "${BOOTSTRAP_SHELL}" && ${BOOTSTRAP_SHELL} == "zsh" ]]; then
		source "${HOME}/.zshrc"
	elif [[ ${CURRENT_SHELL} == "${BOOTSTRAP_SHELL}" && ${BOOTSTRAP_SHELL} == "bash" ]]; then
		source "${HOME}/.bashrc"
	else
		log_event "info" "Your ${GREEN}${BOOTSTRAP_SHELL}${NO_COLOR} plugins will be updated automatically on the next shell start 🚀"
		log_event "info" "Please restart your shell to see the changes take effect 🔄"
	fi
	log_event "info" "Enjoy your new ✨ ${PURPLE}.dotfiles${NO_COLOR} ✨"
	log_event "info" "Bootstrapping ${PURPLE}${DOTFILES_REPO}${NO_COLOR} ${GREEN}complete${NO_COLOR} 🎉"
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
# bootstrap the shell configuration file
bootstrap_shell_config
# initialize shell
start_preferred_shell
