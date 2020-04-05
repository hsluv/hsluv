# Copyright (C) 2020 Sebastian Pipping <sebastian@pipping.org>
# Licensed under the MIT license

FROM ubuntu:18.04

RUN export DEBIAN_FRONTEND=noninteractive \
        && \
    apt-get update \
        && \
    apt-get dist-upgrade --yes --no-install-recommends \
        && \
    apt-get install --yes --no-install-recommends \
            bzip2 \
            ca-certificates \
            curl \
            sudo \
            xz-utils

RUN useradd --create-home --non-unique --uid 1000 nix \
        && \
    echo 'nix ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER nix
ENV USER=nix NIX_CURL_FLAGS='--retry-connrefused --silent --show-error'
RUN mkdir /home/nix/hsluv

RUN curl ${NIX_CURL_FLAGS} -L https://nixos.org/nix/install | sh

# Make sure that all future RUN commands have nix.sh sourced, first.
# NOTE: nix.sh needs ${HOME} and ${USER} set
ENV BASH_ENV=/home/nix/.nix-profile/etc/profile.d/nix.sh
SHELL ["bash", "-c"]

RUN nix-env --version

RUN nix-instantiate --eval -E 'with import <nixpkgs> {}; lib.version or lib.nixpkgsVersion'

COPY --chown=nix:nix default.nix  /home/nix/hsluv/
COPY --chown=nix:nix javascript/  /home/nix/hsluv/javascript/
COPY --chown=nix:nix haxe/        /home/nix/hsluv/haxe/
COPY --chown=nix:nix snapshots/   /home/nix/hsluv/snapshots/
COPY --chown=nix:nix website/     /home/nix/hsluv/website/

WORKDIR /home/nix/hsluv/

RUN nix-build -A test
RUN nix-build -A website
