ROOT_DIR="$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/"

all: shellcheck build test

shellcheck:
	# TODO: remove SC1117 exclusion when on shellcheck > 0.5.0
	$(ROOT_DIR)/tools/shellcheck -e SC1091 \
	                             -e SC1117 \
	                             jenkins-support \
	                             *.sh

build: build-debian build-alpine build-slim build-jdk11

build-debian:
	docker build --file Dockerfile .

build-alpine:
	docker build --file Dockerfile-alpine .

build-slim:
	docker build --file Dockerfile-slim .

build-jdk11:
	docker build --file Dockerfile-jdk11 .

bats:
	git clone https://github.com/sstephenson/bats.git

prepare-test: bats
	git submodule update --init --recursive

test-debian: prepare-test
	DOCKERFILE=Dockerfile bats/bin/bats tests

test-alpine: prepare-test
	DOCKERFILE=Dockerfile-alpine bats/bin/bats tests

test-slim: prepare-test
	DOCKERFILE=Dockerfile-slim bats/bin/bats tests

test-jdk11: prepare-test
	DOCKERFILE=Dockerfile-jdk11 bats/bin/bats tests

test: test-debian test-alpine test-slim test-jdk11

publish:
	./publish.sh' ; \
	sh './publish.sh --variant alpine' ; \
	sh './publish.sh --variant slim'

clean:
	rm -rf tests/test_helper/bats-*; \
	rm -rf bats

.PHONY: shellcheck
