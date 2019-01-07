FROM ubuntu:bionic

ENV USER=githome \
    DEBIAN_FRONTEND=noninteractive

RUN \
    apt update && apt install -y sudo curl mysql-client iputils-ping \
    inotify-tools gnupg build-essential &&\
    curl -O https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb &&\
    dpkg -i erlang-solutions_1.0_all.deb && apt update &&\
    apt install esl-erlang elixir -y &&\
    rm -rf /var/lib/apt/lists/* erlang-solutions_1.0_all.deb &&\
    adduser --disabled-password --gecos '' ${USER} && \
    mkdir -p /etc/sudoers.d/ &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}

USER ${USER}
COPY ./ssh /home/${USER}/.ssh
RUN \
    mix local.hex --force &&\
    mix local.rebar --force &&\
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

WORKDIR /home/${USER}
