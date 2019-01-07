FROM ubuntu:bionic

ENV USER=githome \
    DEBIAN_FRONTEND=noninteractive

RUN \
    apt update && apt install -y sudo curl mysql-client iputils-ping inotify-tools gnupg &&\
    curl -O https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb &&\
    dpkg -i erlang-solutions_1.0_all.deb && apt update &&\
    apt install elixir -y &&\
    rm -rf /var/lib/apt/lists/* erlang-solutions_1.0_all.deb &&\
    adduser --disabled-password --gecos '' ${USER} && \
    mkdir -p /etc/sudoers.d/ &&\
    echo "${USER} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER}

USER ${USER}
COPY ./ssh /home/githome/.ssh

RUN sudo apt update && sudo apt install -y libjson-perl openssh-client perl git &&\
    sudo chown -R ${USER}:${USER} /home/${USER}/ &&\
    git clone https://github.com/sitaramc/gitolite /home/${USER}/gitolite &&\
    mkdir /home/${USER}/bin && /home/${USER}/gitolite/install -ln &&\
    echo "PATH=${PATH}:/home/${USER}/bin" >> /home/${USER}/.bashrc

WORKDIR /home/githome
RUN cp .ssh/id_rsa.pub admin.pub && bin/gitolite setup -pk admin.pub
