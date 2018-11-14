.PHONY: clean req

PROJECT_NAME=githome
MIX=$(shell which mix)
VSN=$(shell ${MIX} ex_app_info.version.get)
TOOLCHAIN="${PROJECT_NAME}-build-toolchain:${VSN}"
TESTS="${PROJECT_NAME}-test-toolchain:${VSN}"
DOCKER=$(shell which docker)

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
	@${DOCKER} build \
    		--tag=${TOOLCHAIN} \
    		--rm \
    		./


cli-toolchain: docker-req
	@${DOCKER} run \
		--volume "${PWD}":/home/githome/project \
		--volume "${HOME}"/.ssh:/home/githome/.ssh \
		--tmpfs /tmp:exec,size=2G \
		--env UID=$(shell id -u) \
		--env GID=$(shell id -g) \
		--privileged \
		--rm \
		${USE_TTY} ${TOOLCHAIN}


deb: req
	@mix release

clean:
	@echo "Clean..."


####################################
