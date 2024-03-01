# dotfiles

This repository contains my personal dotfiles.

Currently, this repository is only configured to set up the ZSH shell
and isn't fully customizable yet. It's compatible with both MacOS and
Linux. More to come soon!

## Installation

### Automatic

```shell
bash -c "`curl -sL https://raw.githubusercontent.com/juftin/dotfiles/main/bootstrap.sh`"
```

<details><summary>Bootstrapping Screen Recording</summary>
<p>

https://github.com/juftin/dotfiles/assets/49741340/40d0f338-b817-4503-b00e-2d3c5c5a820c

</p>
</details>

Try it out in a docker sandbox:

```shell
docker run --rm -it \
  --env TERM \
  --env COLORTERM \
  debian:latest \
  /bin/bash -c \
    'apt update -qq &>/dev/null && \
    apt install -qq -y curl &>/dev/null && \
    bash -c "`curl -sL https://raw.githubusercontent.com/juftin/dotfiles/main/bootstrap.sh`"'
```

### Manual

```shell
git clone https://github.com/juftin/dotfiles.git ~/.dotfiles
```

```shell
[[ ! -f ${HOME}/.dotfiles/dotfiles.zsh ]] || source ${HOME}/.dotfiles/dotfiles.zsh
```
