.PHONY: clean req

PROJECT_NAME=githome
MIX=$(shell which mix)
DCOMP=$(shell which docker-compose)
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
ifdef MIX_ENV
	PARAM+=-e MIX_ENV=${MIX_ENV}
endif

DEV_YML=-f dev.yml

docker-req: req
req:
	@echo ""

dev: docker-req
	${DCOMP} ${DEV_YML} up -d

dev-build: docker-req
	${DCOMP} ${DEV_YML} build

dev-run: docker-req
	${DCOMP} ${DEV_YML} up --build

dev-down: docker-req
	${DCOMP} ${DEV_YML} down

dev-cli: docker-req
	${DCOMP} ${DEV_YML} exec web-dev iex --sname attached --remsh dev@localhost

dev-bash: docker-req
	${DCOMP} ${DEV_YML} exec web-dev /bin/bash

dev-logs: docker-req
	${DCOMP} ${DEV_YML} logs ${APP}

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
		${USE_TTY} ${TOOLCHAIN} \
		/bin/bash

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
	@sudo dpkg -i rel/githome_$(shell mix vsn)_all.deb

remove: req
	@sudo dpkg --remove githome

purge: req
	@sudo dpkg --purge githome

test: docker-req
	${DCOMP} up --build --abort-on-container-exit


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
	@rm -rf rel/distillery_packager/debian/additional_files/usr/bin/gitolite
	@rm -rf rel/distillery_packager/debian/additional_files/usr/lib/githome/gitolite/*


####################################

raw-init: req
	@mix deps.get
	@cd apps/githome_web/assets && npm install && node node_modules/webpack/bin/webpack.js --mode development
	@mix phx.digest

raw-deb: raw-update-vsn raw-gitolite raw-init
	@MIX_ENV=prod ${MIX} release --upgrade

raw-update-vsn:
	@${MIX} vsn.update

raw-compile: raw-init raw-gitolite
	@${MIX} compile

raw-gitolite:
	git submodule update --init
	cd priv/gitolite && ./install -to $(shell pwd)/rel/distillery_packager/debian/additional_files/usr/lib/githome/gitolite
