# Dependencies

_Almost all_ of the dependencies in this project are managed via a
file themselves. For macOS, we use a [Homebrew](https://brew.sh/)
[Brewfile](https://github.com/Homebrew/homebrew-bundle). In Linux,
an [Aptfile](https://github.com/seatgeek/bash-aptfile) is used.

These files are located in the `dotfiles` directory under `macos` and `linux`,
respectively.

## Installation

The `dotfiles deps` command will install the right dependencies for
the current operating system. See the [macOS](#macos) and [Linux](#linux)
sections for the manual installation steps.

```shell
dotfiles deps
```

### Linux

```shell
bash ~/.dotfiles/bin/aptfile ~/.dotfiles/linux/Aptfile
```

<details><summary>📄 Aptfile</summary>
<p>

```shell
--8<-- "linux/Aptfile"
```

</p>
</details>

??? note "Non-Debian Distributions"

    Not all Linux distributions use `apt-get` as their package manager. If you
    are using a `dnf` / `yum` based distribution, the dependencies are enumerated
    in different files.

    ??? note "📄 Yumfile"

        ```shell
        --8<-- "linux/Yumfile"
        ```

    ??? note "📄 AmazonLinuxfile"

        ```shell
        --8<-- "linux/AmazonLinuxfile"
        ```

### macOS

=== "brew"

    ```shell
    brew bundle --file ~/.dotfiles/macos/Brewfile
    ```

=== "dotfiles"

    ```shell
    dotfiles brew-bundle
    ```

<details><summary>📄 Brewfile</summary>
<p>

```shell
--8<-- "macos/Brewfile"
```

</p>
</details>

#### Cleanup

After installing the dependencies, you can run the `cleanup` command to remove
any non-specific dependencies. Add the `--force` flag to actually remove the
packages.

=== "brew"

    ```shell
    brew bundle cleanup --file ~/.dotfiles/macos/Brewfile
    ```

=== "dotfiles"

    ```shell
    dotfiles brew-cleanup
    ```

=== "dotfiles (--force)"

    ```shell
    dotfiles brew-cleanup-force
    ```

#### x86 macOS

This project uses x86 emulation via [Rosetta 2](https://support.apple.com/en-us/HT211861)
on Apple Silicon Macs. Any x86 specific dependencies will be installed via the `XBrewfile`:

=== "xbrew"

    ```shell
    xbrew bundle --file ~/.dotfiles/macos/XBrewfile
    ```

=== "dotfiles"

    ```shell
    dotfiles xbrew-bundle
    ```

### Python

This project uses [pipx](https://github.com/pypa/pipx) to install Python CLI
tools globally. It also includes a `pipx-utils` executable to help manage these
tools on a single `PipxFile`:

=== "pipx-utils"

    ```shell
    pipx-utils install-file ~/.dotfiles/python/PipxFile
    ```

=== "dotfiles"

    ```shell
    dotfiles pipx-install-all
    ```

<details><summary>📄 PipxFile</summary>
<p>

```shell
--8<-- "tools/pipx/PipxFile"
```

</p>
</details>
