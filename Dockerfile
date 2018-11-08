FROM elixir:1.7.3
LABEL author="Roman Mingazeev"
LABEL email="direnol@yandex.ru"
LABEL version="1.0.0"
LABEL description="Toolchain for building deps and run project"

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm
