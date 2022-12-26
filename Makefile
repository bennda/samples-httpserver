# makefile variables
IMAGE_NAME=dnbnt/samples-httpserver
IMAGE_VERSION=1.0
IMAGE_FULLNAME=${IMAGE_NAME}:${IMAGE_VERSION}

.PHONY: help all

help:
	    @echo "Makefile arguments:"
	    @echo ""
		@echo "java-build"
		@echo "java-test"
		@echo "java"
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
		#@docker rm -f javaservertest
		#@docker network rm javaservertest

java: java-build java-test

build: net-build java-build

test: net-test java-test

all: build test