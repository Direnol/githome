FROM elixir:1.7.4
LABEL author="Roman Mingazeev"
LABEL email="direnol@yandex.ru"
LABEL version="1.1.0"
LABEL description="Toolchain for tests"

ENV USER=githome \
    DEBIAN_FRONTEND=noninteractive

RUN \
    adduser --disabled-password --gecos '' ${USER} --home "/home/${USER}" && \
    mkdir -p /etc/sudoers.d/ && sed -i -e 's/#alias/alias/g' "/home/${USER}/.bashrc" &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}

RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh &&\
    bash nodesource_setup.sh && apt-get -y install nodejs mysql-client sudo \
    inotify-tools

USER ${USER}

RUN sudo apt update && sudo apt install -y libjson-perl openssh-client perl git\
    openssh-server &&\
    sudo chown -R ${USER}:${USER} /home/${USER}/ &&\
    git clone https://github.com/sitaramc/gitolite /home/${USER}/gitolite &&\
    mkdir /home/${USER}/bin && /home/${USER}/gitolite/install -ln &&\
    echo "PATH=${PATH}:/home/${USER}/bin" >> /home/${USER}/.bashrc &&\
    ssh-keygen -t rsa -N '' -f /home/${USER}/.ssh/id_rsa

WORKDIR /home/${USER}
RUN cp .ssh/id_rsa.pub admin.pub && bin/gitolite setup -pk admin.pub &&\
    sudo service ssh start  && ssh -o "StrictHostKeyChecking no" localhost &&\
    git clone localhost:gitolite-admin.git admin &&\
    git config --global user.email "admin@noemail.com" &&\
    git config --global user.name "admin" &&\
    echo 'include "groups/*.conf"' > "/home/${USER}/admin/conf/gitolite.conf" &&\
    echo 'include "repos/*.conf"' >> "/home/${USER}/admin/conf/gitolite.conf" &&\
    mkdir "/home/${USER}/admin/conf/repos" "/home/${USER}/admin/conf/groups" &&\
    echo "repo gitolite-admin" > "/home/${USER}/admin/conf/repos/gitolite-admin.conf" &&\
    echo "  RW+     =   admin" >> "/home/${USER}/admin/conf/repos/gitolite-admin.conf" &&\
    cd "/home/${USER}/admin" &&\
    git add . &&\
    git commit -m "Install" &&\
    git push &&\
    rm -rf "/home/${USER}/repositories/testing.git"

RUN \
    mix local.hex --force &&\
    mix local.rebar --force &&\
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

COPY ./run.sh /run.sh
ENTRYPOINT [ "/run.sh" ]

EXPOSE 4000 22
