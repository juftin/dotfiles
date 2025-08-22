# Installation

## Bootstrapping

To install the dotfiles, run the following command:

=== "curl"

    ```shell
    curl -fsSL https://juftin.com/dotfiles/get | bash
    ```

=== "wget"

    ```shell
    wget -qO- https://juftin.com/dotfiles/get | bash
    ```

Try it out in a docker sandbox:

```shell
docker run --rm -it \
 --env TERM \
 --env COLORTERM \
 python:latest \
 /bin/bash -c \
   "curl -fsSL https://juftin.com/dotfiles/get | bash && zsh"
```

### Environment Variables

-   `DOTFILES_REPO`: The repository to clone. Default: `juftin/dotfiles`
-   `DOTFILES_BRANCH`: The branch to check out. Default: `<default branch>`
-   `DOTFILES_DIR`: The directory to clone the repository into. Default: `~/.dotfiles`

## Manual Installation

If you prefer to install the dotfiles manually,
instead of via the bootstrapping script, you can follow
the steps below:

1. Install any missing dependencies

    ```shell
    apt install -y git curl zsh make tar gh
    ```

2. Clone the repo to `~/.dotfiles`

    ```shell
    git clone https://github.com/juftin/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    ```

3. Sync all git submodules

    ```shell
    git submodule update --init --recursive
    ```

4. Link the dotfiles

    ```shell
    # ZSH
    ln -s ~/.dotfiles/bootstrap/oh-my-zsh ~/.oh-my-zsh
    ln -s ~/.dotfiles/bootstrap/fast-syntax-highlighting ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
    ln -s ~/.dotfiles/bootstrap/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    ln -s ~/.dotfiles/bootstrap/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
    ln -s ~/.dotfiles/shell/.zshrc ~/.zshrc
    # BASH
    ln -s ~/.dotfiles/bootstrap/oh-my-bash ~/.oh-my-bash
    ln -s ~/.dotfiles/shell/.bashrc ~/.bashrc
    ln -s ~/.dotfiles/shell/.profile ~/.profile
    # SHELL
    ln -s ~/.dotfiles/shell/.shell_startup ~/.shell_startup
    ln -s ~/.dotfiles/shell/.shell_vars ~/.shell_vars
    ln -s ~/.dotfiles/shell/.shell_aliases ~/.shell_aliases
    ln -s ~/.dotfiles/shell/.shell_functions ~/.shell_functions
    # GIT
    ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
    ln -s ~/.dotfiles/git/.gitignore ~/.gitignore
    # BIN
    ls -s ~/.dotfiles/bin/aptfile /usr/local/bin/aptfile
    ls -s ~/.dotfiles/bin/has /usr/local/bin/has
    ls -s ~/.dotfiles/bin/now /usr/local/bin/now
    ls -s ~/.dotfiles/bin/pacapt /usr/local/bin/pacapt
    # TOOLS
    ln -s ~/.dotfiles/tools/direnv ~/.config/direnv
    ln -s ~/.dotfiles/tools/awsume ~/.awsume
    ln -s ~/.dotfiles/tools/nvim ~/.config/nvim
    ln -s ~/.dotfiles/tools/cargo/env ~/.cargo/env
    ln -s ~/.dotfiles/tools/hatch/config.toml ~/.config/hatch/config.toml
    ln -s ~/.dotfiles/tools/hatch/config.toml ~/.config/pypoetry/config.toml
    ln -s ~/.dotfiles/tools/hammerspoon ~/.hammerspoon
    ```
