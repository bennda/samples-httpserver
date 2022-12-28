# makefile variables
IMAGE_NAME=dnbnt/samples-httpserver
IMAGE_VERSION=1.0
IMAGE_FULLNAME=${IMAGE_NAME}:${IMAGE_VERSION}
NETWORK_NAME=samples-httpserver-test
TEST_CONTAINER_NAME=testserver
SUFFIX_GO=go
SUFFIX_JAVA=java
SUFFIX_NET=net
SUFFIX_PYTHON=python

.PHONY: help all

help:
	    @echo "Makefile arguments:"
	    @echo ""
		@echo "go"
		@echo "java"
	    @echo "net"
		@echo "python"
		@echo "build"
		@echo "test"
	    @echo "all"
		@echo "test-init"
		@echo "test-cleanup"

.DEFAULT_GOAL := all

test-init:
		@echo "\n===== test-init"
		@export NETWORK="$(shell docker network ls --filter name=gotest --format "{{.Name}}")"; \
		if ! [ "$(shell docker network ls --filter name=${NETWORK_NAME} --format "{{.Name}}")" = "${NETWORK_NAME}" ]; then docker network create --driver=bridge --subnet=172.231.0.0/16 ${NETWORK_NAME}; fi;

test-cleanup:
		@echo "\n===== test-cleanup"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}" ]; then docker rm -f ${TEST_CONTAINER_NAME}; fi;
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_GO} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_GO}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_GO}; fi;
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_JAVA} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_JAVA}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_JAVA}; fi;
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_NET} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_NET}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_NET}; fi;
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}; fi;
		@if [ "$(shell docker network ls --filter name=${NETWORK_NAME} --format "{{.Name}}")" = "${NETWORK_NAME}" ]; then docker network rm ${NETWORK_NAME}; fi

go-build:
		@echo "\n===== docker build: go"
		@docker build --no-cache --pull --build-arg BASE_IMAGE=golang --build-arg BASE_VERSION=1.19.4-alpine3.17 -t "${IMAGE_FULLNAME}-go" ./go

go-test:
		@echo "\n===== test: go server"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_GO} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_GO}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_GO}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_GO} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-go
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_GO}:8080/echo?text=hello%20go%20server')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_GO}:8080/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

go: go-build test-init go-test test-cleanup

java-build:
		@echo "\n===== docker build: java server"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-java" ./java

java-test:
		@echo "\n===== test: java server"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_JAVA} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_JAVA}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_JAVA}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_JAVA} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-java
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_JAVA}?text=hello%20webapi')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_JAVA}/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

java: java-build test-init java-test test-cleanup

net-build:
		@echo "\n===== docker build: .net"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-net" ./net

net-test:
		@echo "\n===== test: .net"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_NET} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_NET}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_NET}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_NET} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-net
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_NET}/echo?text=hello%20.net')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_NET}/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

net: net-build test-init net-test test-cleanup

python-build:
		@echo "\n===== docker build: python"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-python" ./python

python-test:
		@echo "\n===== test: python"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-python
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}:8080?mode=echo&text=hello%20python')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}:8080?mode=random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

python: python-build test-init python-test test-cleanup

build: java-build go-build net-build python-build

test: test-init go-test java-test net-test python-test test-cleanup

all: build test