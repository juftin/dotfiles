# ✨ Features

Installation and setup of the `dotfiles` project is the use of an opinionated set of
tools and configurations. These configurations are based on my personal preferences
and are designed to be sensible defaults for most users.

This project functions by symbolically linking the configuration files and directories
in this repository to their appropriate locations on your system. Some tools and
frameworks require that you clone the repository locally, this project uses git
submodules to manage these dependencies.

## Shell Configuration

### Zsh

the Z shell (zsh) is set up with a number of frameworks and plugins to make
your terminal experience more productive and enjoyable:

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

The `dotfiles` command is a wrapper around the `dotfiles` project and provides
a number of useful operations:

```bash exec="on" result="text" title="dotfiles"
make | sed 's/\x1b\[[0-9;]*m//g'
```

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

-   `log_event`: Log an event with a timestamp and a message. Supports different
    levels such as info, error, warning, debug, and critical.

### Executables

-   [aptfile]: Install packages from a file using `apt-get`
-   [has]: Check if a program exists, and its version
-   [now]: Get the current date and time
-   [pacapt]: Universal package manager wrapper

## Python

-   [pyenv] for managing Python versions
-   [pipx] for installing Python CLI tools

### hatch

-   Sensible defaults for `hatch`

??? note "📄 hatch/config.toml"

    ```toml
    --8<-- "tools/hatch/config.toml"
    ```

## git

-   Reasonable settings at `~/.gitconfig`
-   Reasonable global gitignore at `~/.gitignore`
-   `gh` ([GitHub CLI]) for git auth and GitHub interactions

??? note "📄 .gitconfig"

    ```shell
    --8<-- "git/.gitconfig"
    ```

??? note "📄 .gitignore"

    ```shell
    --8<-- "git/.gitignore"
    ```

## Neovim

[Neovim](https://neovim.io/) is a highly configurable, Vim-based text editor.
The configuration of Neovim is managed by the `dotfiles` project and is
configured with the [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
project template.

??? important "Neovim on Linux"

    Not all linux distributions have the latest version of Neovim available
    in their package managers. If this is the case, it is recommended
    to build Neovim from source to get the latest version. The `dotfiles`
    project has exposed a simple command to do this for you:

    ```shell
    dotfiles nvim-build
    ```

    Building Neovim from source requires a number of dependencies, which can be
    installed manually:

    === "apt-get"

        ```shell
        apt-get install ninja-build gettext cmake unzip curl build-essential
        ```

    === "yum (supports direct install)"

        ```shell
        yum install gcc gcc-c++
        yum install neovim
        ```

## Applications and Tools

-   [awsume] is an AWS role management tool configured with `dotfiles`. See the
    [awsume docs](../dev-setup/aws.md#awsume) in `dev-setup` for more information.

### macOS

A good number of macOS-specific applications are installed via Homebrew,
they're enumerated in the `macos/Brewfile` which is documented in the
[dependencies](../dotfiles/dependencies.md) section.

-   [Hammerspoon](https://www.hammerspoon.org/) - installation of the
    [hammerspoon-shiftit](https://github.com/peterklijn/hammerspoon-shiftit)
    plugin which provides window management functionality. See the
    [shiftit docs](../dev-setup/apps.md#shiftit) in `dev-setup` for more information.

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
[pyenv]: https://github.com/pyenv/pyenv
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
[awsume]: https://awsu.me/
[aptfile]: https://github.com/seatgeek/bash-aptfile
[has]: https://github.com/kdabir/has
[now]: https://github.com/apankrat/now.sh
[pacapt]: https://github.com/icy/pacapt
