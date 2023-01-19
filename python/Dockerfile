ARG BASE_IMAGE=python
ARG BASE_VERSION=3.12.0a4-alpine3.17

FROM $BASE_IMAGE:$BASE_VERSION

RUN mkdir /app
COPY server.py /app
WORKDIR /app
ENTRYPOINT [ "python", "/app/server.py" ]