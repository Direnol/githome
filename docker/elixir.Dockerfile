FROM elixir:1.7.4

ENV USER=githome \
    DEBIAN_FRONTEND=noninteractive

RUN \
    adduser --disabled-password --gecos '' ${USER} && \
    mkdir -p /etc/sudoers.d/ &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}

RUN \
    apt update && apt install -y mysql-client

USER ${USER}
COPY ./ssh /home/${USER}/.ssh
RUN \
    mix local.hex --force &&\
    mix local.rebar --force &&\
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

COPY ./run.sh run.sh
ENTRYPOINT [ "/run.sh" ]
WORKDIR /home/${USER}
