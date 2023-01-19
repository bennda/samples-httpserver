# makefile variables
IMAGE_NAME=dnbnt/samples-httpserver
IMAGE_VERSION=1.0
IMAGE_FULLNAME=${IMAGE_NAME}:${IMAGE_VERSION}
NETWORK_NAME=samples-httpserver-test
TEST_CONTAINER_NAME=testserver
SUFFIX_GO=go
SUFFIX_NET=net
SUFFIX_NODE=node
SUFFIX_PYTHON=python

.PHONY: help all

help:
	    @echo "Makefile arguments:"
	    @echo ""
		@echo "go"
	    @echo "net"
		@echo "node"
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
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_NET} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_NET}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_NET}; fi;
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_NODE} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_NODE}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_NODE}; fi;
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}; fi;
		@if [ "$(shell docker network ls --filter name=${NETWORK_NAME} --format "{{.Name}}")" = "${NETWORK_NAME}" ]; then docker network rm ${NETWORK_NAME}; fi

go-build:
		@echo "\n===== docker build: go"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-go" ./go

go-test:
		@echo "\n===== test: go server"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_GO} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_GO}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_GO}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_GO} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-go; sleep 2s
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_GO}:8080/echo?text=hello%20go%20server')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_GO}:8080/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

go: go-build test-init go-test test-cleanup

net-build:
		@echo "\n===== docker build: .net"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-${SUFFIX_NET}" ./net

net-test:
		@echo "\n===== test: .net"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_NET} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_NET}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_NET}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_NET} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-${SUFFIX_NET}
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_NET}/echo?text=hello%20.net')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_NET}/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

net: net-build test-init net-test test-cleanup

node-build:
		@echo "\n===== docker build: node.js"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-${SUFFIX_NODE}" ./node.js

node-test:
		@echo "\n===== test: node.js"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_NODE} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_NODE}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_NODE}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_NODE} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-${SUFFIX_NODE}; sleep 5s
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_NODE}:8080/echo?text=hello%20node.js')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_NODE}:8080/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

node: node-build test-init node-test test-cleanup

python-build:
		@echo "\n===== docker build: python"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-${SUFFIX_PYTHON}" ./python

python-test:
		@echo "\n===== test: python"
		@if [ "$(shell docker ps -a --filter name=${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON} --format "{{.Names}}")" = "${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}" ]; then docker rm -f ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}; fi
		@docker run -d --name ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON} --network ${NETWORK_NAME} ${IMAGE_FULLNAME}-${SUFFIX_PYTHON}
		@ECHO="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s '${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}:8080?mode=echo&text=hello%20python')"; \
		RAND="$$(docker run --rm --network ${NETWORK_NAME} curlimages/curl -s ${TEST_CONTAINER_NAME}-${SUFFIX_PYTHON}:8080?mode=random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"

python: python-build test-init python-test test-cleanup

build: go-build net-build node-build python-build

test: test-init go-test net-test node-test python-test test-cleanup

all: build test