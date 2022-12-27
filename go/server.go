package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"net/url"
	"os"
	"strconv"
)

const DefaultPort = "8080"

func getServerPort() string {
	port := os.Getenv("SERVER_PORT")
	if port != "" {
		return port
	}

	return DefaultPort
}

func getQueryValue(url *url.URL, name string, defaultValue string) string {
	value := url.Query().Get(name)
	if value == "" {
		return defaultValue
	}
	return value
}

func Handler(writer http.ResponseWriter, request *http.Request) {
	log.Println("Echoing back request made to " + request.URL.Path + " to client (" + request.RemoteAddr + ")")

	mode := getQueryValue(request.URL, "mode", "echo")

	switch mode {
	case "echo":
		EchoHandler(writer, request)
	case "random":
		RandomHandler(writer, request)
	default:
		fmt.Fprintf(writer, "Hello World")
	}

	//writer.Header().Set("Access-Control-Allow-Origin", "*")
	//writer.Header().Set("Access-Control-Allow-Headers", "Content-Range, Content-Disposition, Content-Type, ETag")
	//request.Write(writer)
}

func EchoHandler(writer http.ResponseWriter, request *http.Request) {
	text := getQueryValue(request.URL, "text", "")
	fmt.Fprintf(writer, text)
}

func RandomHandler(writer http.ResponseWriter, request *http.Request) {
	min, _ := strconv.Atoi(getQueryValue(request.URL, "minimum", "0"))
	max, _ := strconv.Atoi(getQueryValue(request.URL, "maximum", "1000"))

	fmt.Fprintf(writer, strconv.Itoa(min+rand.Intn(max-min)))
}

func main() {
	log.Println("starting server, listening on port " + getServerPort())

	http.HandleFunc("/", Handler)
	http.HandleFunc("/echo", EchoHandler)
	http.HandleFunc("/random", RandomHandler)
	http.ListenAndServe(":"+getServerPort(), nil)
}
