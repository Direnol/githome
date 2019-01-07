FROM elixir:1.7.4
LABEL author="Roman Mingazeev"
LABEL email="direnol@yandex.ru"
LABEL version="1.1.0"
LABEL description="Toolchain for tests"

ENV USER=githome \
    DEBIAN_FRONTEND=noninteractive

RUN \
    adduser --disabled-password --gecos '' ${USER} && \
    mkdir -p /etc/sudoers.d/ &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}

RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh &&\
    bash nodesource_setup.sh && apt-get -y install nodejs mysql-client

USER ${USER}
COPY ./ssh /home/${USER}/.ssh
RUN \
    mix local.hex --force &&\
    mix local.rebar --force &&\
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

COPY ./run.sh run.sh
ENTRYPOINT [ "/run.sh" ]
WORKDIR /home/${USER}
