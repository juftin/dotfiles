# QuickStart

## Run the [installation](installation.md) script

=== "curl"

    ```shell
    curl -fsSL https://juftin.com/dotfiles/get | bash
    ```

=== "wget"

    ```shell
    wget -qO- https://juftin.com/dotfiles/get | bash
    ```

> [!NOTE]
> If you're not comfortable running a script from the internet,
> check out the [manual installation](installation.md#manual-installation)
> instructions.

## Install any missing [dependencies](dependencies.md)

```shell
dotfiles deps
```

!!! note

    This could also be done with `brew bundle` / `aptfile`

    === "mac"

        ```shell
        brew bundle --file ~/.dotfiles/macos/Brewfile
        ```

    === "linux"

        ```shell
        bash ~/.dotfiles/bin/aptfile ~/.dotfiles/linux/Aptfile
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

## Install Python Versions (Optional)

The following command will install the latest versions
of Python `3.12`, `3.11`, `3.10`, `3.9`, and `3.8`.
`3.11` is the current default.

```shell
dotfiles pyenv-install-all
```

> [!NOTE]
> This is the same as running:
>
> ```shell
> pyenv install 3.11 3.12 3.10 3.9 3.8
> pyenv global 3.11 3.12 3.10 3.9 3.8
> pyenv rehash
> ```
