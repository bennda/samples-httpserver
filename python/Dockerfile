ARG BASE_IMAGE=python
ARG BASE_VERSION=latest

FROM $BASE_IMAGE:$BASE_VERSION

RUN mkdir /app
COPY server.py /app
WORKDIR /app
ENTRYPOINT [ "python", "/app/server.py" ]