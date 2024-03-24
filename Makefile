SHELL := /bin/bash
MAKE_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell uname -s)

##@ dotfiles

.PHONY: bootstrap
bootstrap: ## Initialize the project by running the bootstrap script.
	$(SHELL) $(MAKE_DIR)/bootstrap/bootstrap.sh

.PHONY: deps
deps: ## Install dependencies for the project based on the OS.
ifeq ($(OS),Linux)
	@echo "Installing packages from Aptfile 📦"
	$(SHELL) "$(MAKE_DIR)/bin/aptfile" "$(MAKE_DIR)/linux/Aptfile"
else ifeq ($(OS),Darwin)
	. ~/.shell_functions
	@echo "Installing packages from Brewfile 📦"
	brew bundle --file "$(MAKE_DIR)/macos/Brewfile"
else
	@echo "Unsupported OS: $(OS)"
	exit 1
endif
	@echo "Dependencies installed successfully 🎉"

.PHONY: sync
sync: ## Update the project and its submodules.
	@echo "Updating dotfiles and its submodules 🔄"
	git pull --recurse-submodules --jobs=4
	@echo "Dotfiles synced successfully 🎉"

##@ pyenv

.PHONY: pyenv-install-all
pyenv-install-all: ## Install all python versions into pyenv
	@echo "Installing all python versions into pyenv 🐍"
	pyenv install 3.12 3.11 3.10 3.9 3.8 --skip-existing
	pyenv global 3.11 3.12 3.10 3.9 3.8
	pyenv rehash
	@echo "Python versions installed successfully 🎉"


##@ general

.PHONY: version
version: ## Show the version of the project.
	@git fetch --unshallow 2>/dev/null || true
	@git fetch --tags 2>/dev/null || true
	@echo "dotfiles $$(git describe --tags --abbrev=0)"

##################################################
# dotfiles development - do not autodocument these
##################################################

# Lint with pre-commit
.PHONY: fmt
fmt:
	pre-commit run --all-files

# Build the documentation
.PHONY: docs
docs:
	hatch run docs:serve --livereload

.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help message and exit.
################################################
# Auto-Generated Help:
# - "##@" denotes a target category
# - "##" denotes a specific target description
###############################################
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  dotfiles \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
