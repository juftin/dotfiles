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

# file search functions
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

# check out a branch
function check() {
	git checkout $1
}

# remove local versions of deleted remote branches
function git-remove-deleted() {
	git fetch -p
	for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
		git branch -D $branch
	done
}

# verbose `git status` alias
alias status="git status --verbose --ahead-behind --branch --find-renames"

# AWS 🤝 Docker
function aws-docker-login() {
	AWS_DOCKER_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
	aws ecr get-login-password \
		--region us-east-1 |
		docker login \
			--username AWS \
			--password-stdin ${AWS_DOCKER_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
}

# source the `.zshrc` file
function sync() {
	log_event info "Syncing ZSH Configuration..."
	source ~/.zshrc
	log_event info "ZSH Synced!"
}

if [[ ${OSTYPE} == "darwin"* ]]; then
	[[ ! -f ${DOTFILES_DIR}/shell/zsh/mac/aliases.zsh ]] || source ${DOTFILES_DIR}/shell/zsh/mac/aliases.zsh
fi
