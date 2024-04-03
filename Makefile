SHELL := /bin/bash
MAKE_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell uname -s)

##@ dotfiles 🚀

.PHONY: bootstrap
bootstrap: ## Initialize the project by running the bootstrap script.
	$(SHELL) $(MAKE_DIR)/bootstrap/bootstrap.sh

.PHONY: deps
deps: ## Install dependencies for the project based on the OS.
	$(SHELL) "$(MAKE_DIR)/bin/dotfiles-project-deps"

.PHONY: sync
sync: ## Update the project and its submodules.
	@echo "Updating dotfiles and its submodules 🔄"
	git pull --recurse-submodules --jobs=4
	@echo "Dotfiles synced successfully 🎉"

##@ macOS 🍏

.PHONY: brew-bundle
brew-bundle: ## Install packages from the Brewfile.
	@echo "Installing packages from Brewfile 📦"
	brew bundle --file "$(MAKE_DIR)/macos/Brewfile"
	@echo "Packages installed successfully 🎉"

.PHONY: brew-cleanup
brew-cleanup: ## Cleanup Homebrew, remove unused packages (dry-run).
	@echo "Homebrew cleanup summary 🧹"
	brew bundle cleanup --file "$(MAKE_DIR)/macos/Brewfile"
	@echo "Homebrew cleanup summary complete 🎉"

.PHONY: brew-cleanup-force
brew-cleanup-force: ## Cleanup Homebrew, remove unused packages.
	@echo "Cleaning up Homebrew 🧹"
	brew bundle cleanup --force --file "$(MAKE_DIR)/macos/Brewfile"
	@echo "Homebrew cleaned up successfully 🎉"

.PHONY: xbrew-bundle
xbrew-bundle: ## Install x86 packages from the XBrewfile.
	@echo "Installing x86 packages from XBrewfile 📦"
	xbrew bundle --file "$(MAKE_DIR)/macos/XBrewfile"
	@echo "x86 packages installed successfully 🎉"

.PHONY: xbrew-cleanup
xbrew-cleanup: ## Cleanup x86 Homebrew, remove unused packages (dry-run).
	@echo "x86 Homebrew cleanup summary 🧹"
	xbrew bundle cleanup --file "$(MAKE_DIR)/macos/XBrewfile"
	@echo "x86 Homebrew cleanup summary complete 🎉"

.PHONY: xbrew-cleanup-force
xbrew-cleanup-force: ## Cleanup x86 Homebrew, remove unused packages.
	@echo "Cleaning up x86 Homebrew 🧹"
	xbrew bundle cleanup --force --file "$(MAKE_DIR)/macos/XBrewfile"
	@echo "x86 Homebrew cleaned up successfully 🎉"

##@ python 🐍

.PHONY: pyenv-install-all
pyenv-install-all: ## Install all python versions into pyenv.
	@echo "Installing all python versions into pyenv 🐍"
	pyenv install 3.12 3.11 3.10 3.9 3.8 --skip-existing
	pyenv global 3.11 3.12 3.10 3.9 3.8
	pyenv rehash
	@echo "Python versions installed successfully 🎉"

.PHONY: pyenv-compile
pyenv-compile: ## Compile pyenv bash extension to optimize performance.
	@echo "Compiling pyenv bash extension to optimize performance 🚀"
	bash ~/.pyenv/src/configure
	make -C ~/.pyenv/src
	@echo "Pyenv bash extension compiled successfully 🎉"

.PHONY: pipx-install-all
pipx-install-all: ## Install pipx packages from PipxFile
	@echo "Installing pipx packages from PipxFile 📦"
	$(MAKE_DIR)/bin/pipx-utils install-file "$(MAKE_DIR)/tools/pipx/PipxFile"
	@echo "pipx packages installed successfully 🎉"

##@ nvim 🌌

.PHONY: nvim-build
nvim-build: ## Build Neovim from source.
	@echo "Building Neovim from source 🚀"
	$(MAKE_DIR)/bin/neovim-install
	@echo "Neovim built successfully 🎉"

##@ rust 🦀

.PHONY: rust-install
rust-install: ## Install Rust and its components.
	@echo "Installing Rust and its components 🦀"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	@echo "Rust installed successfully 🎉"

##@ general 🌐

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
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  dotfiles \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-19s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
