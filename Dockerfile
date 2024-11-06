ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim AS builder

RUN apt update \
    && apt install -y sudo git curl zsh tar gh make

ENV HOME=/root
ENV DOTFILES_DIR=${HOME}/.dotfiles
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
WORKDIR ${HOME}

COPY --chown=juftin:juftin . ${DOTFILES_DIR}

RUN make -C ${HOME}/.dotfiles bootstrap

SHELL ["/bin/zsh", "-c"]

RUN make -C ${HOME}/.dotfiles deps
RUN apt clean && rm -rf /var/lib/apt/lists/*

RUN make -C ${HOME}/.dotfiles pyenv-compile
RUN ${DOTFILES_DIR}/bootstrap/pyenv/bin/pyenv global system
RUN ${DOTFILES_DIR}/bootstrap/pyenv/bin/pyenv rehash
RUN make -C ${HOME}/.dotfiles uv-install
RUN make -C ${HOME}/.dotfiles nvim-build
RUN ${DOTFILES_DIR}/bin/install-awscli

RUN pipx install "browsr[all]"

RUN /bin/zsh -c "echo exit | script -qec zsh /dev/null >/dev/null"

CMD ["/bin/zsh"]
