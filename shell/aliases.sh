##########################################################
##################### SHELL ALIASES ######################
##########################################################

alias c="clear"
alias cls="clear"
alias ls="ls -G -a -F"

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
	log_event info "Working On Git Branch: ${1}"
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
