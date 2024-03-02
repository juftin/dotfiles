# dotfiles

This repository contains my personal dotfiles.

## Installation

### Automatic

```shell
bash -c "`curl -sL https://raw.githubusercontent.com/juftin/dotfiles/main/bootstrap.sh`"
```

<details><summary>Bootstrapping Screen Recording</summary>
<p>

https://github.com/juftin/dotfiles/assets/49741340/fe45fa6a-96a5-401a-b40a-e1ee4fc4d9cf

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
