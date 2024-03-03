-include .env
export

today ?= ${shell date '+%Y%m%d'}

override date ?= ${today}
override distro ?= leap

.PHONY: all build clean test
all: # TODO
clean: # TODO
test: # TODO

build-base: dockerfile ?= Dockerfile.base-${distro}
build-base: ${dockerfile}
	docker buildx build --load \
		-f '${dockerfile}' \
		-t 'docker.io/michelecereda/boinc-client:base-${distro}-${BOINC_CLIENT_VERSION}-${date}' \
		'.'

build-intel: dockerfile ?= Dockerfile.intel-${distro}
build-intel: ${dockerfile}
	docker buildx build --load \
		--build-arg \
			'BOINC_CLIENT_VERSION=${BOINC_CLIENT_VERSION}'
			'BASE_IMAGE_VERSION=${date}'
		-f '${dockerfile}' \
		-t 'docker.io/michelecereda/boinc-client:intel-${distro}-${BOINC_CLIENT_VERSION}-${date}' \
		'.'

build-amd: dockerfile ?= Dockerfile.amd-${distro}
build-amd: ${dockerfile}
	docker buildx build --load \
		--build-arg \
			'BOINC_CLIENT_VERSION=${BOINC_CLIENT_VERSION}'
			'BASE_IMAGE_VERSION=${date}'
		-f '${dockerfile}' \
		-t 'docker.io/michelecereda/boinc-client:amd-${distro}-${BOINC_CLIENT_VERSION}-${date}' \
		'.'

build: build-base build-intel build-amd

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
