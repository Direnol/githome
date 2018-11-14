.PHONY: clean req

PROJECT_NAME=githome
VSN=$(grep -o version[^,]* mix.exs | awk '{ print $2 }' | sed s/\"//g)
TOOLCHAIN=${PROJECT_NAME}:${VSN}

USE_TTY = -ti
# При работе в контексте Gitlab-ci, нам не нужен интерактивный режим и эмуляция TTY
ifdef CI_RUNNER_ID
	undefine USE_TTY
endif

docker-req: req
req:
	@echo ""

init: req
	@mix deps.get
	@cd assets && npm install
	@mix ecto.create

tc: toolchain
toolchain: docker-req
	@docker build -t ${TOOLCHAIN} ./

cli: docker-req
	@docker run \
		--env UID=$(shell id -u) \
		--env GID=$(shell id -g) \
		--privileged \
		--rm \
		${USE_TTY} ${TOOLCHAIN}

clean:
	@echo "Clean..."


####################################
