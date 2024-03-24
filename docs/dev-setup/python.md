# Python

> [!IMPORTANT] dotfiles
> If you're using the dotfiles from this project,
> `pyenv` and `pipx` are installed and configured
> automatically - see the [features](../dotfiles/features.md)
> section for more information on what's included.

Install and manage python versions using [pyenv].

## pyenv

This process uses [pyenv] to manage Python installation and versions. [pyenv] is a Python
version manager that can manage and install different versions of Python.

Install [pyenv] with [homebrew]

```shell
brew install pyenv
```

Add the following lines to update your `~/.zshrc` / `~/.zprofile` files,
instructing them to use [pyenv] to manage Python:

```shell
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

Install additional dependencies required to build Python

=== "mac"

    ```shell
    brew install openssl readline sqlite3 xz zlib tcl-tk
    ```

=== "linux"

    ```shell
    apt update
    apt install \
        build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev \
        curl libncursesw5-dev xz-utils \
        tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev
    ```

```shell
pyenv install 3.11 3.12 3.10 3.9 3.8
pyenv global 3.11 3.12 3.10 3.9 3.8
pyenv rehash
```

### Upgrading Python Versions

When you run the above `pyenv` command to install the multiple Python
versions pyenv will install new versions of the respective minor versions
of Python. For example, `3.11.7` to `3.11.8`. This is useful but can
cause some unintended consequences.

In the below example, the default Python version, `3.11`, was upgraded. In
this case we uninstall the old version and recreate all `pipx` applications
that were installed using the old version and also recreate any virtual
environments.

```console
$ pyenv versions
   system
 * 3.8.19 (set by /Users/juftin/.pyenv/version)
 * 3.9.19 (set by /Users/juftin/.pyenv/version)
 * 3.10.13 (set by /Users/juftin/.pyenv/version)
   3.11.7
 * 3.11.8 (set by /Users/juftin/.pyenv/version)
 * 3.12.2 (set by /Users/juftin/.pyenv/version)
$ pyenv uninstall 3.11.7
```

```shell
pipx reinstall-all
```

```shell
rm -rf .venv
python -m venv .venv
source .venv/bin/activate
```

![pyenv.png]

## IPython

Install [IPython]

```shell
pip install 'ipython[zmq,qtconsole,notebook,test]'
```

![ipython.png]

## pipx

Install [pipx]

pipx is a tool to help you install and run end-user applications written in
Python. It's roughly similar to macOS's brew, JavaScript's npx, and
Linux's apt.

It's closely related to pip. In fact, it uses pip, but is focused on installing
and managing Python packages that can be run from the command line directly as
applications.

```shell
brew install pipx
pipx ensurepath
```

Add the following lines to update your `~/.zshrc` file, instructing it to use
`pyenv`'s default Python version to bootstrap `pipx` applications:

```shell
export PIPX_DEFAULT_PYTHON=$(pyenv which python)
```

![pipx_demo.gif]

[Python]: https://python.org/
[pipx]: https://github.com/pypa/pipx
[pyenv]: https://github.com/yyuu/pyenv
[IPython]: http://ipython.org/
[homebrew]: https://brew.sh/
[pyenv.png]: https://i.imgur.com/aBtVsdd.png
[ipython.png]: https://i.imgur.com/pu16vey.png
[pipx_demo.gif]: https://i.imgur.com/eS1t3Mc.gif
