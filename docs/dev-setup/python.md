# Python

> [!IMPORTANT] dotfiles
> If you're using the dotfiles from this project,
> `uv` is installed and configured
> automatically - see the [features](../dotfiles/features.md)
> section for more information on what's included.

Install and manage python versions using [uv].

## uv

This process uses [uv] to manage Python installation and versions. [uv] is an extremely fast Python package and project manager, written in Rust, that can manage and install different versions of Python.

Install [uv] with their install script:

```shell
curl -LsSf https://astral.sh/uv/install.sh | sh
```

No additional shell configuration is needed as [uv] manages Python versions automatically when needed.

Install Python versions using [uv]:

```shell
uv python install 3.12 3.11 3.10 3.9
uv python install 3.13 --default --preview-features python-install-default
```

## IPython

Install [IPython]

```shell
uv tool add 'ipython[zmq,qtconsole,notebook,test]'
```

![ipython.png]

## uv tool

[uv tool] is built into uv and helps you install and run end-user applications written in
Python. It's roughly similar to macOS's brew, JavaScript's npx, and
Linux's apt.

It's closely related to pip but is focused on installing
and managing Python packages that can be run from the command line directly as
applications.

Since `uv tool` is built into uv, no additional installation is needed:

```shell
uv tool install <package-name>
```

[Python]: https://python.org/
[uv tool]: https://docs.astral.sh/uv/guides/tools/
[uv]: https://docs.astral.sh/uv/
[IPython]: http://ipython.org/
[ipython.png]: https://i.imgur.com/pu16vey.png
