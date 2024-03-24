# SSH

## Set up a new SSH Key

```shell
ssh-keygen -t ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
```

Done. Your public key is now saved to your clipboard.
