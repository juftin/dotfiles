<div align="center">
  <a href="https://github.com/juftin/dotfiles">
    <img src="https://raw.githubusercontent.com/juftin/dotfiles/main/docs/logo.png" alt="dotfiles" width="500" />
  </a>
  <p align="center">
    my personal dotfiles for <code>zsh</code>, <code>bash</code>, and more
  </p>
  <a href="https://github.com/juftin/dotfiles/"><img src="https://img.shields.io/github/v/release/juftin/dotfiles?color=blue&label=dotfiles&logo=slashdot" alt="docs"></a>
  <a href="https://juftin.com/dotfiles/"><img src="https://img.shields.io/static/v1?message=docs&color=526CFE&logo=Material+for+MkDocs&logoColor=FFFFFF&label=" alt="docs"></a>
  <a href="https://github.com/pre-commit/pre-commit"><img src="https://img.shields.io/badge/pre--commit-enabled-lightgreen?logo=pre-commit" alt="pre-commit"></a>
  <a href="https://github.com/semantic-release/semantic-release"><img src="https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg" alt="semantic-release"></a>
  <a href="https://gitmoji.dev"><img src="https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg" alt="Gitmoji"></a>
</div>

## Installation

### Automatic

```shell
curl -fsSL https://juftin.com/dotfiles/get | bash
```

When using the bootstrapping script, the following steps are taken:

1. Install any missing dependencies (e.g. `git`, `zsh`, `curl`, `tar`)
2. Clone this project into `~/.dotfiles`
3. Symbolically link the dotfiles into their proper locations

<!--skip-->
<details><summary>🌈 Bootstrapping Screen Recording</summary>
<p>

https://github.com/juftin/dotfiles/assets/49741340/569d7e27-114b-4378-9157-f7f9e9de52fc

</p>
</details>
<!--skip-->

#### Optional Environment Variables

-   `DOTFILES_REPO`: The repository to clone. Default: `juftin/dotfiles`
-   `DOTFILES_BRANCH`: The branch to checkout. Default: `<default branch>`
-   `DOTFILES_DIR`: The directory to clone the repository into. Default: `~/.dotfiles`

> INFO:
>
> Try it out in a docker sandbox:
>
> ```shell
> docker run --rm -it \
>  --env TERM \
>  --env COLORTERM \
>  python:latest \
>  /bin/bash -c \
>    "curl -fsSL https://juftin.com/dotfiles/get | bash && zsh"
> ```

### Manual

1. Install any missing dependencies

    ```shell
    apt install -y git curl zsh tar
    ```

2. Clone the repo to `~/.dotfiles`

    ```shell
    git clone https://github.com/juftin/dotfiles.git ~/.dotfiles
    ```

3. Sync all git submodules

    ```shell
    cd ~/.dotfiles
    git submodule update --init --recursive
    ```

4. Link the dotfiles

    ```shell
    ln -s ~/.dotfiles/bootstrap/oh-my-zsh ~/.oh-my-zsh
    ln -s ~/.dotfiles/bootstrap/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
    ln -s ~/.dotfiles/bootstrap/fast-syntax-highlighting ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
    ln -s ~/.dotfiles/bootstrap/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    ln -s ~/.dotfiles/bootstrap/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
    ln -s ~/.dotfiles/bootstrap/oh-my-bash ~/.oh-my-bash
    ln -s ~/.dotfiles/shell/.zshrc ~/.zshrc
    ln -s ~/.dotfiles/shell/.bashrc ~/.bashrc
    ln -s ~/.dotfiles/shell/.profile ~/.profile
    ln -s ~/.dotfiles/shell/.p10k.zsh ~/.p10k.zsh
    ln -s ~/.dotfiles/shell/.shell_aliases ~/.shell_aliases
    ln -s ~/.dotfiles/shell/.mac_aliases ~/.mac_aliases
    ln -s ~/.dotfiles/bootstrap/pyenv ~/.pyenv
    ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
    ln -s ~/.dotfiles/git/.gitignore ~/.gitignore
    ```

## Customization

Customizing this repo for yourself requires editing a few key
files:

-   `~/.gitconfig`
    -   Update the `[user]` section with your own name and email
