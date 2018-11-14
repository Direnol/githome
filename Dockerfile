FROM ubuntu:bionic
LABEL author="Roman Mingazeev"
LABEL email="direnol@yandex.ru"
LABEL version="1.0.0"
LABEL description="Toolchain for building deps and run project"

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm \
    ELIXIR_VSN=1.7.3-1 \
    USER=githome \
    IN_DOCKER=true

ADD https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb /tmp

RUN \
    sed -i 's|http://|http://ru.|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install gnupg -y && \
    dpkg -i /tmp/erlang-solutions_1.0_all.deb && \
    apt-get update && apt-get install -y \
    make esl-erlang elixir=${ELIXIR_VSN} locales \
    lsb-release npm sudo && \
    rm -rf /var/cache/*

RUN \
    adduser --disabled-password --gecos '' ${USER} && \
    mkdir -p /etc/sudoers.d/ &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER} &&\
    adduser ${USER} sudo && \
    locale-gen en_US.UTF-8 ru_RU.UTF-8 &&\
    update-locale LANG=ru_RU.UTF-8 && \
    update-locale LC_ALL=ru_RU.UTF-8

USER ${USER}

RUN \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

EXPOSE 4000

WORKDIR /home/githome/project
