FROM elixir:1.7.4
LABEL author="Roman Mingazeev"
LABEL email="direnol@yandex.ru"
LABEL version="1.1.0"
LABEL description="Toolchain for building deb package"

ENV USER=githome \
    DEBIAN_FRONTEND=noninteractive

RUN \
    adduser --disabled-password --gecos '' ${USER} --home "/home/${USER}" && \
    mkdir -p /etc/sudoers.d/ && sed -i -e 's/#alias/alias/g' "/home/${USER}/.bashrc" &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}

RUN \
    apt update && apt install -y sudo node-global-modules make build-essential

COPY ./docker/ssh /home/${USER}/.ssh

RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get -y install nodejs

USER ${USER}
RUN \
    mix local.hex --force &&\
    mix local.rebar --force &&\
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

WORKDIR /home/${USER}/project
