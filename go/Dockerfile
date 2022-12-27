ARG BASE_IMAGE=golang
ARG BASE_VERSION=latest

FROM $BASE_IMAGE:$BASE_VERSION

RUN mkdir /app
COPY server.go /app
WORKDIR /app
ENTRYPOINT [ "go", "run", "./server.go" ]