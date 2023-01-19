FROM golang:alpine as build
WORKDIR /src
COPY *.go .
RUN go build -o /server *.go

FROM alpine:latest
WORKDIR /app
COPY --from=build /server .

ENTRYPOINT [ "./server" ]