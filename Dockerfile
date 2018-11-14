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
    update-locale LANG=en_US.UTF-8 &&\
    sudo -u ${USER} mix local.hex --force && \
    sudo -u ${USER} mix loca.rebar --force && \
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force

USER ${USER}
EXPOSE 4000

WORKDIR /home/githome/project
