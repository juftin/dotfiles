SHELL := /bin/bash
OS := $(shell uname -s)
GIT := git
HATCH := hatch

.PHONY: help
help:
	@echo "Usage: make [TARGET] ..."
	@echo ""
	@echo "Targets:"
	@echo "  bootstrap  Initialize the project by running the bootstrap script."
	@echo "  deps       Install dependencies for the project based on the OS."
	@echo "  docs       Serve the documentation locally."
	@echo "  fmt        Run pre-commit hooks on all files."
	@echo "  help       Show this help message."
	@echo "  sync       Update the project and its submodules."

.PHONY: bootstrap
bootstrap:
	$(SHELL) ./bootstrap/bootstrap.sh

.PHONY: deps
deps:
ifeq ($(OS),Linux)
	$(SHELL) ./bin/aptfile ./linux/Aptfile
else ifeq ($(OS),Darwin)
	brew bundle --file=./macos/Brewfile
else
	$(error Unsupported operating system - $(OS))
endif

.PHONY: sync
sync:
	$(GIT) pull --recurse-submodules --jobs=4

.PHONY: fmt
fmt:
	pre-commit run --all-files

.PHONY: docs
docs:
	$(HATCH) run docs:serve --livereload
