ARG BASE_IMAGE=openjdk
ARG BASE_VERSION=latest

FROM $BASE_IMAGE:$BASE_VERSION as builder
WORKDIR /code/
COPY *.java ./
RUN javac Server.java

FROM $BASE_IMAGE:$BASE_VERSION
RUN mkdir /app
COPY --from=builder /code /app/
WORKDIR /app
ENTRYPOINT [ "java", "Server" ]