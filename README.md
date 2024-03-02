<div align="center">
  <a href="https://github.com/juftin/dotfiles">
    <img src="https://raw.githubusercontent.com/juftin/dotfiles/main/docs/logo.png" alt="dotfiles" width="500" />
  </a>
</div>

<p align="center">
my personal dotfiles
</p>

## Installation

### Automatic

```shell
curl -fsSL https://juftin.com/dotfiles/get | bash
```

<!--skip-->
<details><summary>🌈 Bootstrapping Screen Recording</summary>
<p>

https://github.com/juftin/dotfiles/assets/49741340/9c96b82e-8a39-49bc-af3f-f513048adcc5

</p>
</details>
<!--skip-->

Try it out in a docker sandbox:

```shell
docker run --rm -it \
  --env TERM \
  --env COLORTERM \
  --env BOOTSTRAP_SHELL=zsh \
  debian:latest \
  /bin/bash -c \
    "apt update -qq &>/dev/null && \
    apt install -qq -y curl &>/dev/null && \
    curl -fsSL https://juftin.com/dotfiles/get | bash && \
    zsh"
```

#### Optional Environment Variables

-   `BOOTSTRAP_SHELL`: The shell to use for bootstrapping. Default: `zsh`, options: `zsh`, `bash`
-   `DOTFILES_REPO`: The repository to clone. Default: `juftin/dotfiles`
-   `DOTFILES_BRANCH`: The branch to checkout.
-   `DOTFILES_DIR`: The directory to clone the repository into. Default: `~/.dotfiles`

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
