# QuickStart

## Install Base Dependencies

Install `curl` / `wget` to download the installation script:

=== "mac"

    ```shell
    brew install curl wget
    ```

=== "linux"

    ```shell
    sudo apt update
    sudo apt install -y curl wget
    ```

## Run the [installation](installation.md) script

=== "curl"

    ```shell
    curl -fsSL https://juftin.com/dotfiles/get | bash
    ```

=== "wget"

    ```shell
    wget -qO- https://juftin.com/dotfiles/get | bash
    ```

## Install any missing [dependencies](dependencies.md)

```shell
dotfiles deps
```

## Set `zsh` as the default shell

If not already set, update the default shell to `zsh`:

```shell
chsh -s $(which zsh)
zsh
```

## Set up `git` credentials

```shell
gh auth login
```

## Install Python Versions:

```shell
pyenv install 3.12 3.11 3.10 3.9 3.8
pyenv global 3.12 3.11 3.10 3.9 3.8
pyenv rehash
```
