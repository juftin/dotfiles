SHELL := /bin/bash
OS := $(shell uname -s)

##@ dotfiles

.PHONY: bootstrap
bootstrap: ## Initialize the project by running the bootstrap script.
	$(SHELL) ./bootstrap/bootstrap.sh

.PHONY: deps
deps: ## Install dependencies for the project based on the OS.
ifeq ($(OS),Linux)
	$(SHELL) ./bin/aptfile ./linux/Aptfile
else ifeq ($(OS),Darwin)
	brew bundle --file=./macos/Brewfile
else
	$(error Unsupported operating system - $(OS))
endif

.PHONY: sync
sync: ## Update the project and its submodules.
	git pull --recurse-submodules --jobs=4

##@ development

.PHONY: fmt
fmt: ## Run pre-commit hooks on all files.
	pre-commit run --all-files

.PHONY: docs
docs: ## Serve the documentation locally.
	hatch run docs:serve --livereload

##@ general

.PHONY: version
version: ## Show the version of the project.
	@echo "dotfiles $$(git describe --tags --abbrev=0)"

.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help message and exit.
################################################
# Auto-Generated Help:
# - "##@" denotes a target category
# - "##" denotes a specific target description
###############################################
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
