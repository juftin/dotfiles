# Initial Settings and Applications

> [!IMPORTANT] dotfiles
> If you're using the dotfiles from this project,
> these tools can be installed automatically -
> see the [dependencies](../dotfiles/dependencies.md)
> section for more information on how to install them.

## Initial Settings

### Trackpad & Mouse

-   `Point & Click`
    -   Enable `Tap to click with one finger`
    -   Change `Secondary click` to `Right corner`
    -   Uncheck `Three Finger Drag`
-   `Scroll & Zoom`
    -   Uncheck `all` apart from `Zoom in and out`
    -   Uncheck `Scolling girection: natural`

### General Settings

-   Enable Dark Mode
    -   `System Preferences` -> `General`
-   Disable Recent Apps in Dock
    -   `System Preferences` -> `Dock & Menu Bar` -> Uncheck `Show recent applications in dock`

#### Show Hidden Files

Show hidden files inside the `finder` app

```shell
defaults write com.apple.finder AppleShowAllFiles True; killall Finder
```

![hidden_files.png]

#### Screenshots Directory

Set new default screenshot Dir

```shell
mkdir ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots/ && killall SystemUIServer
```

#### Workplace Auto Switch

Disable Workspace Auto Switching

```shell
defaults write com.apple.dock workspaces-auto-swoosh -bool NO
killall Dock
```

## Initial Applications

### Google Chrome

Download and install [Google Chrome] Web Browser

-   https://www.google.com/chrome/downloads/

![chrome.png]

### 1Password

Download and install [1Password]

-   https://1password.com/downloads/mac/

![1password.png]

[Google Chrome]: https://google.com/chrome
[1Password]: https://1password.com/
[1password.png]: https://i.imgur.com/NynHW6y.png
[chrome.png]: https://i.imgur.com/yHhWjHB.png
[hidden_files.png]: https://i.imgur.com/1SpPj9m.png
