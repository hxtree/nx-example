# syntax=docker/dockerfile:1
################################################################################
#                                     Base                                     #
################################################################################
# https://hub.docker.com/_/node
# https://github.com/nodejs/release#nodejs-release-working-group
FROM node:hydrogen-bookworm as base

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV HOME /home/node

RUN mkdir /usr/src/app

WORKDIR /usr/src/app

RUN apt update \
    && apt install -y --no-install-recommends \
        tzdata \
        build-essential \
        curl \
        zip \
        unzip \
        less \
        jq \
        npm \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
    && dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
    && npm install --global npm@9.7.2  \
    # https://rushjs.io/pages/maintainer/enabling_prettier/
    && npm install --global prettier \
    && npm install --global lint-staged \
    # install conventional commits
    && npm install --global @commitlint/config-conventional \
    && npm install --global @commitlint/cli \
    && npm install --global nx \
    # https://yarnpkg.com/getting-started/install
    && corepack enable

################################################################################
#                                  Test Base                                   #
################################################################################
FROM base AS test
ARG USER=node

COPY . /usr/src/app

RUN chown -R $USER /usr/src/app \
    && install -d -m 0755 -o $USER /home/$USER/.rush \
    && install -d -m 0755 -o $USER /usr/src/app/common/temp \
    && git config --global --add safe.directory /usr/src/app

USER $USER

WORKDIR /usr/src/app

RUN rush install

SHELL ["/bin/bash", "-c"]

################################################################################
#                               Development Base                               #
################################################################################
FROM base AS development
ARG UID=1000
ARG USER=node

ENV AWS_SDK_LOAD_CONFIG=1
ENV STAGE=default

RUN apt update \
    && apt install -y --no-install-recommends \
    sudo \
    zsh \
    vim

#RUN adduser --home /home/$USER --shell /bin/zsh $USER \
RUN usermod -aG sudo $USER \
    && passwd -d $USER  \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers \
    && chown -R $USER /usr/src/app \
    && install -d -m 0755 -o $USER /home/$USER/.rush \
    && install -d -m 0755 -o $USER /usr/src/app/common/temp \
    && install -d -m 0755 -o $USER /home/$USER/.vscode-server/extensions

# Add alias
RUN echo "alias app=\"cd /usr/src/app\"" >>/home/$USER/.zshrc

# Auto create remote branch on push
RUN git config --global push.default current \
    && git config --global push.autoSetupRemote true

RUN chown -R $USER /home/$USER

USER $USER

# git credentials https://github.com/microsoft/vscode-remote-release/issues/720#issuecomment-503492715
ENV HOME /home/$USER

# pnpm exec esbuild requires this for to access esbuild global
# CDK NodeJsFunction requires esbuild to be installed globally due to the deps lock file being root
ENV PNPM_HOME=/usr/local/sbin
ENV PROJECT_ROOT=/usr/src/app

SHELL ["/bin/zsh", "-c"]
