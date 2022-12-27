# makefile variables
IMAGE_NAME=dnbnt/samples-httpserver
IMAGE_VERSION=1.0
IMAGE_FULLNAME=${IMAGE_NAME}:${IMAGE_VERSION}

.PHONY: help all

help:
	    @echo "Makefile arguments:"
	    @echo ""
		@echo "go"
		@echo "java"
	    @echo "net"
		@echo "build"
		@echo "test"
	    @echo "all"

.DEFAULT_GOAL := all

go-build:
		@echo "\n===== docker build: go"
		@docker build --no-cache --pull --build-arg BASE_IMAGE=golang --build-arg BASE_VERSION=1.19.4-alpine3.17 -t "${IMAGE_FULLNAME}-go" ./go

go-test:
		@echo "\n===== test: go init";
		@export NETWORK="$(shell docker network ls --filter name=gotest --format "{{.Name}}")"; \
		if [ "$(shell docker ps --filter name=gotest --format "{{.Names}}")" = "gotest" ]; then docker rm -f "gotest"; fi; \
		if [ "$(shell docker network ls --filter name=gotest --format "{{.Name}}")" = "gotest" ]; then docker network rm gotest; fi;
		@docker network create --driver=bridge --subnet=172.231.0.0/16 gotest
		@docker run -d --name "gotest" --network gotest ${IMAGE_FULLNAME}-go
		@echo "\n===== test: go server"; \
		ECHO="$$(docker run --rm --network gotest curlimages/curl -s 'gotest:8080/echo?text=hello%20go%20server')"; \
		RAND="$$(docker run --rm --network gotest curlimages/curl -s gotest:8080/random)"; \
		echo "echo: $$ECHO"; \
		echo "rand: $$RAND"
		@echo "\n===== test: go cleanup"
		@docker rm -f gotest
		@docker network rm gotest

go: go-build go-test

java-build:
		@echo "\n===== docker build: java server"
		@docker build --no-cache --pull -t "${IMAGE_FULLNAME}-java-server" ./java

java-test:
		@echo "\n===== test: java server init";
		@export NETWORK="$(shell docker network ls --filter name=javaservertest --format "{{.Name}}")"; \
		if [ "$(shell docker ps --filter name=javaservertest --format "{{.Names}}")" = "javaservertest" ]; then docker rm -f "javaservertest"; fi; \
		if [ "$(shell docker network ls --filter name=javaservertest --format "{{.Name}}")" = "javaservertest" ]; then docker network rm javaservertest; fi;
		@docker network create --driver=bridge --subnet=172.231.0.0/16 javaservertest
		@docker run -d -p 80:80 --name "javaservertest" --network javaservertest ${IMAGE_FULLNAME}-java-server
		@echo "\n===== test: java server"; \
		ECHO="$$(docker run --rm --network javaservertest curlimages/curl -s 'javaservertest?text=hello%20webapi')"; \
		#RAND="$$(docker run --rm --network javaservertest curlimages/curl -s javaservertest/random)"; \
		echo "echo: $$ECHO"; \
		#echo "rand: $$RAND"
		@echo "\n===== test: cleanup"
		@docker rm -f javaservertest
		@docker network rm javaservertest

java: java-build java-test

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

build: java-build go-build net-build

test: go-test java-test net-test

all: build test