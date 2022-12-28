from random import randint
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

host = "0.0.0.0"
port = 8080

class SimpleHttpServer(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()

        values = parse_qs(urlparse(self.path).query)        
        mode = values.get("mode", "echo")[0]

        match mode:
            case "echo":
                result = values.get("text", "")[0]
            case "random":
                min = values.get("min", 0)
                max = values.get("max", 1000)
                result = str(randint(min, max))

        self.wfile.write(bytes(str(result), "utf-8"))

if __name__ == "__main__":
    server = HTTPServer((host, port), SimpleHttpServer)
    print("server started: http://%s:%s" % (host, port))

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass

    server.server_close()
    print("server exit.")
