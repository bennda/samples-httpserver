# makefile variables
IMAGE_NAME=dnbnt/samples-httpserver
IMAGE_VERSION=1.0
IMAGE_FULLNAME=${IMAGE_NAME}:${IMAGE_VERSION}

.PHONY: help all

help:
	    @echo "Makefile arguments:"
	    @echo ""
	    @echo "net-build"
		@echo "net-test"
		@echo "net"
		@echo "build"
		@echo "test"
	    @echo "all"

.DEFAULT_GOAL := all

net-build:
		@echo "\n===== docker build: .net"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-net" ./net

net-test:
		@echo "\n===== test: init";
		@export NETWORK="$(shell docker network ls --filter name=maketest --format "{{.Name}}")"; \
		if [ "$(shell docker ps --filter name=net --format "{{.Names}}")" = "net" ]; then docker rm -f "net"; fi; \
		if [ "$(shell docker network ls --filter name=maketest --format "{{.Name}}")" = "maketest" ]; then docker network rm maketest; fi;
		@docker network create --driver=bridge --subnet=172.231.0.0/16 maketest
		@docker run -d -p 8088:80 --name "net" --network maketest ${IMAGE_FULLNAME}-net
		@echo "\n===== test: .net"; \
		ECHO="$$(docker run --rm --network maketest curlimages/curl -s 'net/echo?text=hello%20.net')"; \
		RAND="$$(docker run --rm --network maketest curlimages/curl -s net/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"
		@echo "\n===== test: cleanup"
		@docker rm -f net
		@docker network rm maketest

net: net-build net-test

build: net-build

test: net-test

all: build test