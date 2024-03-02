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
/bin/bash -c "$(curl -fsSL https://juftin.com/dotfiles/get)"
```

<!--skip-->
<details><summary>Bootstrapping Screen Recording</summary>
<p>

https://github.com/juftin/dotfiles/assets/49741340/fe45fa6a-96a5-401a-b40a-e1ee4fc4d9cf

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
    'apt update -qq &>/dev/null && \
    apt install -qq -y curl &>/dev/null && \
    /bin/bash -c "$(curl -fsSL https://juftin.com/dotfiles/get)" && \
    zsh'
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
