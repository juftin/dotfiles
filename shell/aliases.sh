##########################################################
##################### SHELL ALIASES ######################
##########################################################

alias c="clear"
alias cls="clear"
alias ls="ls -G -a -F"

# Logging
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

# File search functions
function f() {
	find . -iname "*$1*" ${@:2}
}
function r() {
	grep "$1" ${@:2} -R .
}

# Create a folder and move into it in one command
function mkcd() {
	mkdir -p "$@" && cd "$_"
}

# CHECKOUT A GIT BRANCH
function check() {
	git checkout $1
}

# REMOVE LOCAL VERSIONS OF DELETED REMOTE BRANCHES
function git-remove-deleted() {
	git fetch -p
	for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
		git branch -D $branch
	done
}

# GIT STATUS - VERBOSE BY DEFAULT
alias status="git status --verbose --ahead-behind --branch --find-renames"
