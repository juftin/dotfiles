<div align="center">
  <a href="https://github.com/juftin/dotfiles">
    <img src="https://raw.githubusercontent.com/juftin/dotfiles/main/docs/logo.png" alt="dotfiles" width="500" />
  </a>
  <p align="center">
    my personal dotfiles for <code>zsh</code>, <code>bash</code>, and <i>everything else</i>
  </p>
  <a href="https://github.com/juftin/dotfiles/"><img src="https://img.shields.io/github/v/release/juftin/dotfiles?color=blue&label=dotfiles&logo=slashdot" alt="docs"></a>
  <a href="https://juftin.com/dotfiles/"><img src="https://img.shields.io/static/v1?message=docs&color=526CFE&logo=Material+for+MkDocs&logoColor=FFFFFF&label=" alt="docs"></a>
  <a href="https://github.com/pre-commit/pre-commit"><img src="https://img.shields.io/badge/pre--commit-enabled-lightgreen?logo=pre-commit" alt="pre-commit"></a>
  <a href="https://github.com/semantic-release/semantic-release"><img src="https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg" alt="semantic-release"></a>
  <a href="https://gitmoji.dev"><img src="https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg" alt="Gitmoji"></a>
</div>

## Installation

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

https://github.com/juftin/dotfiles/assets/49741340/6c04d3aa-8821-41a9-98d4-74e8b4465f58

</p>
</details>
<!--skip-->

See the documentation for more information on manual installation.

## Dependencies

All packages, applications, and dependencies for this project
can be installed using the provided `dotfiles-deps` command:

```shell
dotfiles-deps
```

On macOS, this command will install dependencies using [Homebrew](https://brew.sh/)'s
`bundle` command and a `Brewfile`. On Linux, this command will install dependencies using `apt-get`
and an `Aptfile`.

## Customization

Customizing this repo for yourself requires editing a few key
files:

-   `~/.gitconfig`
    -   Update the `[user]` section with your own name and email

<!--skip-->

## Documentation

The full documentation for this project is available at
[https://juftin.com/dotfiles/](https://juftin.com/dotfiles/).

-   [Features](docs/features.md)
-   [Installation](docs/installation.md)

<!--skip-->
