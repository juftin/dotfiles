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
	brew bundle --upgrade --file "$(MAKE_DIR)/macos/Brewfile"
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

.PHONY: python-install-all
python-install-all: ## Install all python versions onto your system.
	@echo "Installing all python versions into ~/.local/bin 🐍"
	uv python install 3.13 3.12 3.11 3.10 3.9
	uv python install 3.12 --default --preview-features python-install-default
	@echo "Python versions installed successfully 🎉"

.PHONY: uv-tool-install-all
uv-tool-install-all: ## Install Python CLI packages from PipFile
	@echo "Installing Python packages from UvToolFile 📦"
	$(MAKE_DIR)/bin/uv-tool-utils install-file "$(MAKE_DIR)/tools/uv/UvToolFile"
	@echo "Python packages installed successfully 🎉"

.PHONY: uv-install
uv-install: ## Install uv Python manager.
	$(MAKE_DIR)/bin/uv-install

##@ nvim 🌌

.PHONY: nvim-build
nvim-build: ## Build Neovim from source.
	@echo "Building Neovim from source 🚀"
	$(MAKE_DIR)/bin/neovim-install
	@echo "Neovim built successfully 🎉"

##@ rust 🦀

.PHONY: rust-install
rust-install: ## Install Rust and its components.
	$(MAKE_DIR)/bin/rust-install

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

# Build the Docker Image
.PHONY: docker-build
docker-build:
	docker build -t juftin/juftin:latest .

# Run the Docker Image
.PHONY: docker-run
docker-run:
	docker run --rm -it --env TERM --env COLORTERM juftin/juftin:latest

# Pull / Recreate all Submodules
.PHONY: submodules
submodules:
	git submodule update --init --recursive --remote --jobs=4
	git pull --recurse-submodules --jobs=4

.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help message and exit.
################################################
# Auto-Generated Help:
# - "##@" denotes a target category
# - "##" denotes a specific target description
###############################################
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  dotfiles \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-19s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
