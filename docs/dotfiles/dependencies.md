# Dependencies

_Almost all_ of the dependencies in this project are managed via a
file themselves. For macOS, we use a [Homebrew](https://brew.sh/)
[Brewfile](https://github.com/Homebrew/homebrew-bundle). In Linux,
an [Aptfile](https://github.com/seatgeek/bash-aptfile) is used.

Thesese files are located in the `dotfiles` directory under `macos` and `linux`,
respectively.

## Installation

The `dotfiles-deps` alias will install the right dependencies for
the current operating system. See the [macOS](#macos) and [Linux](#linux)
sections for the manual installation steps.

```shell
dotfiles-deps
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

### macOS

```shell
brew bundle --file=~/.dotfiles/macos/Brewfile
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

```shell
brew bundle cleanup --file=~/.dotfiles/macos/Brewfile
```

#### x86 macOS

This project uses x86 emulation via [Rosetta 2](https://support.apple.com/en-us/HT211861)
on Apple Silicon Macs. Any x86 specific dependencies will be installed via the `XBrewfile`:

```shell
xbrew bundle --file=~/.dotfiles/macos/XBrewfile
```
