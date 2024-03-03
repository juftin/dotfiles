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

1. Install any missing dependencies (e.g. `git`, `zsh`, `curl`, `grep`, `autojump`)
2. Clone this project into `~/.dotfiles`
3. Source the `dotfiles.zsh` or `dotfiles.bash` file in your shell configuration

<!--skip-->
<details><summary>🌈 Bootstrapping Screen Recording</summary>
<p>

https://github.com/juftin/dotfiles/assets/49741340/9c96b82e-8a39-49bc-af3f-f513048adcc5

</p>
</details>
<!--skip-->

#### Optional Environment Variables

-   `BOOTSTRAP_SHELL`: The shell to use for bootstrapping. Default: `zsh`, options: `zsh`, `bash`
-   `DOTFILES_REPO`: The repository to clone. Default: `juftin/dotfiles`
-   `DOTFILES_BRANCH`: The branch to checkout.
-   `DOTFILES_DIR`: The directory to clone the repository into. Default: `~/.dotfiles`

> INFO:
>
> Try it out in a docker sandbox:
>
> ```shell
> docker run --rm -it \
>  --env TERM \
>  --env COLORTERM \
>  --env BOOTSTRAP_SHELL=zsh \
>  debian:latest \
>  /bin/bash -c \
>    "apt update &>/dev/null && \
>    apt install -y curl &>/dev/null && \
>    curl -fsSL https://juftin.com/dotfiles/get | bash && \
>    zsh"
> ```

### Manual

```shell
git clone https://github.com/juftin/dotfiles.git ~/.dotfiles
```

#### zsh

`~/.zshrc`:

```shell
[[ ! -f ${HOME}/.dotfiles/dotfiles.zsh ]] || source ${HOME}/.dotfiles/dotfiles.zsh
```

#### bash

`~/.bashrc`:

```shell
[[ ! -f ${HOME}/.dotfiles/dotfiles.bash ]] || source ${HOME}/.dotfiles/dotfiles.bash
```
