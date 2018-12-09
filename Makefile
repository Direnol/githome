.PHONY: clean req

PROJECT_NAME=githome
MIX=$(shell which mix)
VSN=latest
TOOLCHAIN="${PROJECT_NAME}-build-toolchain:${VSN}"
TESTS="${PROJECT_NAME}-test-toolchain:${VSN}"
DOCKER=$(shell which docker)
MAKE=$(shell which make)
PARAM=--volume "${PWD}":/home/githome/project \
		--volume "${HOME}"/.ssh:/home/githome/.ssh \
		--tmpfs /tmp:exec,size=2G \
		--env UID=$(shell id -u) \
		--env GID=$(shell id -g) \
		--privileged \
		--cap-add=ALL \
		--rm

USE_TTY = -ti
# При работе в контексте Gitlab-ci, нам не нужен интерактивный режим и эмуляция TTY
ifdef CI_RUNNER_ID
	undefine USE_TTY
endif

docker-req: req
req:
	@echo ""

tc: toolchain
toolchain: docker-req
	@${DOCKER} build \
    		--tag=${TOOLCHAIN} \
    		--rm \
    		./

cli: cli-toolchain
cli-toolchain: docker-req
	@${DOCKER} run \
		${PARAM} \
		${USE_TTY} ${TOOLCHAIN}

background: docker-req
	@${DOCKER} run \
		${PARAM} \
		--detach \
		${TOOLCHAIN} \
		mix phx.server

deb: docker-req
	@${DOCKER} run \
		${PARAM} \
		${USE_TTY} ${TOOLCHAIN} \
		${MAKE} raw-deb

install: req
	@sudo dpkg -i rel/githome_0.1.0_all.deb

remove: req
	@sudo dpkg --remove githome

purge: req
	@sudo dpkg --purge githome

test: docker-req
	@${DOCKER} run \
		${PARAM} \
		${TOOLCHAIN}
		${MAKE} raw-test


init: docker-req
	@${DOCKER} run \
		${PARAM} \
		${USE_TTY} ${TOOLCHAIN} \
		${MAKE} raw-init

compile: docker-req
	@${DOCKER} run \
		${PARAM} \
		${TOOLCHAIN}
		${MAKE} raw-compile

clean:
	@echo "Clean..."
	@rm -rf ./_build ./deps rel/*.deb


####################################

raw-test: req
	@echo "Tests..."
	# @${MIX} test

raw-init: req
	@mix deps.get
	@cd assets && npm install && node node_modules/webpack/bin/webpack.js --mode development
	@mix phx.digest
	# @${MIX} ecto.create

raw-deb: raw-init
	@MIX_ENV=prod ${MIX} release

raw-compile: raw-init
	@${MIX} compile