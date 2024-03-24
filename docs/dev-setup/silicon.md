# Apple Silicon

Starting with certain models introduced in late 2020, Apple began the transition
from Intel processors to Apple silicon in Mac computers.

Software is created with specific hardware in mind. In the past, software was made
for Macs with Intel processors, which use the `x86` instruction set. Now,
software needs to be created for both Intel and Apple silicon (which uses the `ARM` instruction set)
in order for the software to work efficiently and properly for each platform.

## Rosetta

For some apps that aren’t re-made for Apple’s silicon, Apple's Rosetta2 software will
take apps made for Intel processors and translate them to run on Apple’s own
ARM-based processors.

**Install Rosetta 2**

```shell
softwareupdate --install-rosetta --agree-to-license
```

In addition to configuring Homebrew for M1, add a second Homebrew installation for
the `x86_64` architecture.

```shell
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

By default, simply use the brew command when installing any brew packages,
but add an alias to your startup files for the `x86` version of
Homebrew, such as the following. This will allow you to easily install dependencies
that are only supported on the `x86_64` architecture. You can add the following
line to your `~/.zshrc` or similar file:

```shell
alias xbrew="arch -x86_64 /usr/local/bin/brew"
```

## Python

One of the largest incompatibilities for Python and Apple Silicon machines is the
availability of wheels for compiled packages. Compiled packages are typically python
modules with components written in other programming languages: like `numpy`, `pandas`,
`pytorch`, etc.

When maintainers upload a compiled package to PyPI they also will typically upload
compiled wheel (binary) files which come with variants for your exact system:
`MacOS x ARM x Python 3.11`. However for older versions of the packages and python versions it is
common for these wheels to be missing for our `MacOS x ARM` machines.

To fix this issue of wheel compatibility of our systems we will use [Rosetta] to
install and use an `x86` version of Python instead. This way we can use `x86` versions
of the wheels for packages which can be much more widely available.

1. Install your base `x86` Version of Python

    - The example above is for `Python 3.8` but it’s good to have one
      installed for all major versions.

    ```shell
    xbrew install "python@3.8"
    ```

2. Create a Virtual Environment in your repository’s `.venv` directory using that `x86` Python

    ```shell
    "$(xbrew --prefix python@3.8)/bin/python3.8" -m venv .venv
    ```

3. Activate the `x86` Python Virtual Environment you just created.

    ```shell
    source .venv/bin/activate
    ```

4. Install any tools or requirements you might need

    - Using `x86` python versions to run tools like `tox`, which
      creates its own virtual environments, can be especially important
      as the underlying virtual environments managed by these tools will also be `x86`

    ```shell
    python -m pip install "tox<4"
    python -m tox
    ```

[Rosetta]: https://support.apple.com/en-us/HT211861
