# Terminal Configuration

## Terminal Setup

### Xcode

Install [Xcode] using the built-in `Terminal` app

```shell
xcode-select --install
```

> [!WARNING] XCode
> `XCode` is an essential tool for any developer on macOS. It provides
> a suite of tools for developing software on Apple platforms. You must
> have `XCode` installed before you can install other tools like `Homebrew`.

### Homebrew

Install [Homebrew] using the built-in `Terminal` app

[Homebrew] calls itself "The missing package manager for macOS" and is an essential tool for
any developer.

> [!NOTE]
> Before you can run [Homebrew] you need to have the Command Line Tools
> for [Xcode](#xcode) installed.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

![homebrew.png]

> [!WARNING] Homebrew
> `Homebrew` is an essential tool for any developer on macOS. It provides
> a streamlined way to install software packages and libraries on your
> system. You must have `Homebrew` installed before you can install other
> tools mentioned in this guide.

### iTerm2

> [!NOTE]
> If you're using the dotfile dependency installation
> method, iTerm2 is installed automatically
> via Homebrew - see the [dependencies](../dotfiles/dependencies.md)
> section for more information.

Install [iTerm2]

[iTerm2] is an open source replacement for Apple's Terminal. It's highly customizable and comes
with a lot of useful features.

```shell
brew install --cask iterm2
```

![iterm2.png]

## Terminal Customization

### Hotkey Shortcut

Create a custom hot-key to launch [iTerm2] from
anywhere: (`^` + `⌥` + `⌘` + `i`)

-   `iTerm2 Preferences` -> `Keys` -> `Hotkey` -> `Create dedicated hotkey window`
-   Set iTerm2 to open (hidden) at login: `System Preferences` -> `Users & Groups`
    -> `Login Items`
-   If not already, set all profiles to use the `MesloLGS NF` font
    in `iTerm2 Preferences` -> `Profile` -> `Text` -> `Font`

> [!NOTE]
> The `MesloLGS Nerd Font` font is included in the `dotfiles` > [dependency installation](../dotfiles/dependencies.md) automatically.
> If you'd like to install it manually, you can do so via homebrew:
>
> ```shell
> brew install --cask font-meslo-lg-nerd-font
> ```

![iterm_hotkey.png]

## Zsh

When leveraging the `dotfiles` from this project, the Z shell (zsh) is set up
with a number of frameworks and plugins to make your terminal experience more
productive and enjoyable:

-   Frameworks and Themes
    -   [ohmyzsh/oh-my-zsh] - The framework for managing your zsh shell
    -   [romkatv/powerlevel10k] - A powerful OhMyZSH theme and prompt
-   OhMyZsh Plugins
    -   [oh-my-zsh/git] - Git aliases and functions
    -   [oh-my-zsh/dotenv] - Loads environment variables from `.env` for the current directory
    -   [oh-my-zsh/macos] - macOS-specific configuration for zsh
    -   [oh-my-zsh/z] - Tracks your most used directories, based on 'frecency'
    -   [oh-my-zsh/web-search] - Search the web from the terminal
    -   [oh-my-zsh/nvm] -nvm (the Node Version Manager) plugin
    -   [oh-my-zsh/asdf] - asdf (the extendable version manager) plugin
    -   [zdharma-continuum/fast-syntax-highlighting] - Syntax highlighting for zsh
    -   [zsh-users/zsh-autosuggestions] - Fish-like autosuggestions for zsh
    -   [zsh-users/zsh-completions] - Additional completion definitions for zsh

[Xcode]: https://developer.apple.com/xcode/
[Homebrew]: https://brew.sh/
[iTerm2]: https://www.iterm2.com/
[ohmyzsh/oh-my-zsh]: https://github.com/ohmyzsh/oh-my-zsh
[zdharma-continuum/fast-syntax-highlighting]: https://github.com/zdharma-continuum/fast-syntax-highlighting
[zsh-users/zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[romkatv/powerlevel10k]: https://github.com/romkatv/powerlevel10k
[oh-my-zsh/git]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
[oh-my-zsh/dotenv]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
[oh-my-zsh/macos]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
[oh-my-zsh/autojump]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/autojump
[oh-my-zsh/web-search]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/web-search
[oh-my-zsh/nvm]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm
[oh-my-zsh/z]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z
[oh-my-zsh/asdf]: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/asdf
[zsh-users/zsh-completions]: https://github.com/zsh-users/zsh-completions
[zsh-users/zsh-history-substring-search]: https://github.com/zsh-users/zsh-history-substring-search
[homebrew.png]: https://i.imgur.com/cZuyeHS.png
[iterm2.png]: https://i.imgur.com/TcQzpxh.png
[iterm_hotkey.png]: https://i.imgur.com/nHjizNi.png
