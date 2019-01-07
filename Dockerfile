FROM elixir:1.7.4
LABEL author="Roman Mingazeev"
LABEL email="direnol@yandex.ru"
LABEL version="1.1.0"
LABEL description="Toolchain for building deb package"

ENV USER=githome \
    DEBIAN_FRONTEND=noninteractive

RUN \
    adduser --disabled-password --gecos '' ${USER} && \
    mkdir -p /etc/sudoers.d/ &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}

RUN \
    apt update && apt install -y make build-essential

USER ${USER}
COPY ./docker/ssh /home/${USER}/.ssh
RUN \
    mix local.hex --force &&\
    mix local.rebar --force &&\
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

ENTRYPOINT [ "/bin/bash" ]
WORKDIR /home/${USER}/project
