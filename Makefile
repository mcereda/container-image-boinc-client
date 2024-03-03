-include .env
export

today ?= ${shell date '+%Y%m%d'}

override date ?= ${today}
override distro ?= leap

.PHONY: all build clean test
all: # TODO
build: build-base build-intel build-amd
clean: # TODO
test: # TODO

%-amd: image ?= amd
%-base: image ?= base
%-intel: image ?= intel

tag ?= docker.io/michelecereda/boinc-client:${image}-${distro}-${BOINC_CLIENT_VERSION}-${date}

build-%: dockerfile ?= Dockerfile.${image}-${distro}
build-%: ${dockerfile}
	docker buildx build --load \
		-f '${dockerfile}' \
		-t '${tag}' \
		'.'
	${MAKE} update-compose-%

update-compose-%: composefile ?= docker-compose.${image}-${distro}.yml
update-compose-%: ${composefile}
	yq -y \
		--arg 'tag' '${tag}' \
		'.services."boinc-client".image=$$tag' \
		'${composefile}' \
	| sponge '${composefile}'

run-base:
	docker run --rm --name 'boinc-client' \
		--net='host' \
		--pid='host' \
		--cap-add 'SYS_NICE' \
		-v '$${PWD}/data:/var/lib/boinc' \
		-e BOINC_CMD_LINE_OPTIONS='--allow_remote_gui_rpc' \
		'docker.io/michelecereda/boinc-client:base-${distro}-${BOINC_CLIENT_VERSION}-${date}'

run-intel: /dev/dri
	docker run --rm --name 'boinc-client' \
		--net='host' \
		--pid='host' \
		--cap-add 'SYS_NICE' \
		--device '/dev/dri:/dev/dri' \
		-v '$${PWD}/data:/var/lib/boinc' \
		-e BOINC_CMD_LINE_OPTIONS='--allow_remote_gui_rpc' \
		'docker.io/michelecereda/boinc-client:intel-${distro}-${BOINC_CLIENT_VERSION}-${date}'

run-amd: /dev/dri /dev/kfd
	docker run --rm --name 'boinc-client' \
		--net='host' \
		--pid='host' \
		--cap-add 'SYS_NICE' \
		--device '/dev/dri:/dev/dri' \
		--device '/dev/kfd:/dev/kfd' \
		--group-add 'video' \
		-v '$${PWD}/data:/var/lib/boinc' \
		-e BOINC_CMD_LINE_OPTIONS='--allow_remote_gui_rpc' \
		'docker.io/michelecereda/boinc-client:amd-${distro}-${BOINC_CLIENT_VERSION}-${date}'
