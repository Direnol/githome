FROM ubuntu:bionic
LABEL author="Roman Mingazeev"
LABEL email="direnol@yandex.ru"
LABEL version="1.0.0"
LABEL description="Toolchain for building deps and run project"

ENV DEBIAN_FRONTEND=noninteractive \
    USER=githome \
    TERM=xterm

RUN adduser --disabled-password --gecos '' ${USER}

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get --yes --no-install-recommends install apt-utils

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get --yes --no-install-recommends install \
    bash bash-completion \
    chrpath curl debconf debhelper devscripts \
    dh-make dh-systemd dirmngr dpkg dput-ng \
    fakeroot gnupg build-essential\
    libsystemd-dev lintian locales make \
    python-paramiko ssh sudo wget ca-certificates

RUN DEBIAN_FRONTEND=noninteractive \
    cd /tmp && \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    sudo dpkg -i erlang-solutions_1.0_all.deb

RUN DEBIAN_FRONTEND=noninteractive \
    sudo apt-get update && \
    sudo apt-get --yes --no-install-recommends install esl-erlang elixir lsb-release

WORKDIR /home/${USER}/project
VOLUME [ "home/${USER}/project" ]
#TODO: Изменить на bash -e чтобы в случае ошибки падал докер
ENTRYPOINT ["/bin/bash"]
CMD["/bin/bash"]