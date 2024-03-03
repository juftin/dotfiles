# Dotfiles

The `dotfiles` project is a collection of configuration files for
the `bash` and `zsh` shells and more.

```shell
juftin/dotfiles
├── bootstrap.sh  # (1)!
├── cache  # (2)!
│   └── zsh  # (3)!
├── dotfiles.bash  # (4)!
├── dotfiles.zsh  # (5)!
└── shell  # (6)!
    ├── aliases.sh  # (7)!
    ├── bash  # (8)!
    │   └── prompt.sh  # (9)!
    ├── settings.sh  # (10)!
    └── zsh  # (11)!
        ├── antidote.zsh  # (12)!
        ├── history.zsh  # (13)!
        ├── mac  # (14)!
        │   └── aliases.zsh  # (15)!
        ├── settings.zsh  # (16)!
        ├── theme.zsh  # (17)!
        └── zsh_plugins.txt  # (18)!
```

1. installation script that bootstraps the dotfiles (`./bootstrap.sh`)
2. cache directory for project files (`./cache/`)
3. zsh cache directory (`./cache/zsh/`)
4. root config file for the bash shell (`./dotfiles.bash`)
5. root config file for the zsh shell (`./dotfiles.zsh`)
6. shell directory - containing all shell config files (`./shell/`)
7. global aliases file for the shell (`./shell/aliases.sh`)
8. bash shell config directory (`./shell/bash/`)
9. bash prompt file - [OhMyBash] (`./shell/bash/prompt.sh`)
10. global settings file for the shell (`./shell/settings.sh`)
11. zsh shell config directory (`./shell/zsh/`)
12. zsh plugin manager config ([antidote]) (`./shell/zsh/antidote.zsh`)
13. zsh history settings file (`./shell/zsh/history.zsh`)
14. mac-specific zsh config directory (`./shell/zsh/mac/`)
15. mac-specific aliases file for the zsh shell (`./shell/zsh/mac/aliases.zsh`)
16. zsh specific settings (`./shell/zsh/settings.zsh`)
17. zsh theme file ([powerlevel10k]) (`./shell/zsh/theme.zsh`)
18. zsh plugin list file (managed by [antidote]) (`./shell/zsh/zsh_plugins.txt`)

## Dotfiles

-   `bootstrap.sh` - The installation script that bootstraps the dotfiles.
-   `dotfiles.bash` - The root config file for the `bash` shell.
-   `dotfiles.zsh` - The root config file for the `zsh` shell.

## `shell`

The `shell` directory contains all of the shell-specific configuration files.
This includes the global settings, aliases, and prompt files, as well as the
shell-specific settings for `bash` and `zsh`.

### `shell/zsh`

The `shell/zsh` directory contains all of the `zsh`-specific configuration files.
This includes the [antidote] plugin manager, the [powerlevel10k] theme, and the
`zsh` settings and aliases.

### `shell/bash`

The `shell/bash` directory contains all of the `bash`-specific configuration files.
This includes the `bash` prompt file, and the `bash` settings and aliases. The bash
prompt file is managed by [OhMyBash].

[antidote]: https://github.com/mattmc3/antidote
[OhMyBash]: https://github.com/ohmybash/oh-my-bash
[powerlevel10k]: https://github.com/romkatv/powerlevel10k
