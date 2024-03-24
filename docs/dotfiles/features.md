# ✨ Features

Installation and setup of the `dotfiles` project is the use of an opinionated set of
tools and configurations. These configurations are based on my personal preferences
and are designed to be sensible defaults for most users.

## Shell Configuration

### Zsh

the Z shell (zsh) is set up
with a number of frameworks and plugins to make your terminal experience more
productive and enjoyable:

-   Frameworks and Themes
    -   [ohmyzsh/oh-my-zsh] - The framework for managing your zsh shell
    -   [romkatv/powerlevel10k] - A powerful OhMyZSH theme and prompt
-   oh-my-zsh Plugins
    -   [oh-my-zsh/git] - Git aliases and functions
    -   [oh-my-zsh/dotenv] - Loads environment variables from `.env` for the current directory
    -   [oh-my-zsh/macos] - macOS-specific configuration for zsh
    -   [oh-my-zsh/z] - Tracks your most used directories, based on 'frecency'
    -   [oh-my-zsh/web-search] - Search the web from the terminal
    -   [oh-my-zsh/nvm] -nvm (the Node Version Manager) plugin
    -   [oh-my-zsh/asdf] - asdf (the extendable version manager) plugin
    -   [zdharma-continuum/fast-syntax-highlighting] - Syntax highlighting for zsh
    -   [zsh-users/zsh-autosuggestions] - Fish-like autosuggestions for zsh
    -   [zsh-users/zsh-completions] - Additional completion definitions for zsh

### Aliases

-   `c` - clear the terminal
-   `ll` - list files in long format
-   `xbrew` - x86 homebrew (macOS only)

### Functions

#### Dotfiles Management

The `dotfiles` command is a wrapper around the `dotfiles` directory and provides
a number of useful operations:

-   `dotfiles sync`: Sync the dotfiles.
-   `dotfiles bootstrap`: Bootstrap the dotfiles.
-   `dotfiles deps`: Install dependencies from Brewfile or Aptfile.

#### Directory Operations

-   `mkcd`: Create a directory and change to it.
-   `mktmpdir`: Create a temporary directory.
-   `ideacd`: Open a directory in the IDE and switch to it.
-   `runin`: Run command in another directory and return.

#### Git Operations

-   `check`: Checkout a branch.
-   `git-remove-deleted`: Remove branches that have been deleted.
-   `git-tree`: Display a tree considering `.gitignore`.

#### Search Operations

-   `f`: Find a file by name.
-   `r`: Grep recursively.

#### Miscellaneous Tasks

-   `is_command`: Check if a command exists.
-   `date_iso8601`: Generate an ISO8601 formatted date string.
-   `hash_sha256`: Generate a SHA-256 hash of a file, string, or stdin.
-   `untar`: Unpack a tarball or zip file.

#### AWS Operations

-   `aws-docker-login`: Login to AWS ECR.

#### Logging

-   `log_event`: Log an event with a timestamp and a message. Supports different levels such as info, error, warning, debug, and critical.

This document is intended to serve as a quick reference guide for the specified CLI commands and shell functions.

## Python

-   [pyenv] for managing Python versions
-   [pipx] for installing Python CLI tools

## git

-   Reasonable settings at `~/.gitconfig`
-   Reasonable global gitignore at `~/.gitignore`
-   `gh` ([GitHub CLI]) for git auth and GitHub interactions

## Applications and Tools

### macOS

A good number of macOS-specific applications are installed via Homebrew,
they're enumerated in the `macos/Brewfile` which is documented in the
[dependencies](../dotfiles/dependencies.md) section.

### Linux

Similarly, a good number of Linux-specific applications are installed via Apt,
they're enumerated in the `linux/Aptfile` which is documented in the
[dependencies](../dotfiles/dependencies.md) section.

[OhMyBash]: https://github.com/ohmybash/oh-my-bash
[powerlevel10k]: https://github.com/romkatv/powerlevel10k
[OhMyZsh]: https://ohmyz.sh/
[zsh-users/zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[zsh-users/zsh-completions]: https://github.com/zsh-users/zsh-completions
[zdharma-continuum/fast-syntax-highlighting]: https://github.com/zdharma-continuum/fast-syntax-highlighting
[aliases]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
[pipx]: https://github.com/pypa/pipx
[pyenv]: https://github.com/yyuu/pyenv
[ohmyzsh/oh-my-zsh]: https://github.com/ohmyzsh/oh-my-zsh
[zdharma-continuum/fast-syntax-highlighting]: https://github.com/zdharma-continuum/fast-syntax-highlighting
[zsh-users/zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[romkatv/powerlevel10k]: https://github.com/romkatv/powerlevel10k
[oh-my-zsh/git]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
[oh-my-zsh/dotenv]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
[oh-my-zsh/macos]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
[oh-my-zsh/autojump]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/autojump
[oh-my-zsh/web-search]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/web-search
[oh-my-zsh/nvm]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm
[oh-my-zsh/z]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z
[oh-my-zsh/asdf]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf
[zsh-users/zsh-completions]: https://github.com/zsh-users/zsh-completions
[zsh-users/zsh-history-substring-search]: https://github.com/zsh-users/zsh-history-substring-search
[GitHub CLI]: https://cli.github.com/
