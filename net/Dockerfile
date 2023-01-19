ARG BASE_IMAGE=mcr.microsoft.com/dotnet/aspnet
ARG BASE_VERSION=7.0.2-alpine3.17-amd64

FROM mcr.microsoft.com/dotnet/sdk:latest AS builder
WORKDIR /code/
COPY . ./
RUN dotnet publish -o /app -c release

FROM $BASE_IMAGE:$BASE_VERSION
WORKDIR /app
COPY --from=builder /app/* /app/

ENTRYPOINT [ "/app/webapi" ]