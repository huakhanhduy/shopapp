import http.server
import urllib.request
import urllib.error
import sys
import os

PORT = 8000
BACKEND_URL = "http://localhost:3000"
WEB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "frontend/shopapp_frontend/build/web"))

class ProxyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_request(self):
        path = self.path
        # Route API and local assets (images/uploads) to backend
        if path.startswith('/api/') or path.startswith('/assets/images/') or path.startswith('/assets/uploads/'):
            url = f"{BACKEND_URL}{path}"
            
            # Read request body
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length) if content_length > 0 else None
            
            # Prepare headers
            headers = {k: v for k, v in self.headers.items()}
            headers.pop('Host', None) # Remove Host header to prevent backend routing issues
            
            req = urllib.request.Request(
                url, 
                data=body, 
                headers=headers, 
                method=self.command
            )
            
            hop_by_hop = {
                'connection', 'keep-alive', 'proxy-authenticate', 
                'proxy-authorization', 'te', 'trailers', 
                'transfer-encoding', 'upgrade'
            }
            
            try:
                with urllib.request.urlopen(req) as response:
                    self.send_response(response.status)
                    data = response.read()
                    
                    for k, v in response.getheaders():
                        if k.lower() not in hop_by_hop and k.lower() != 'content-length':
                            self.send_header(k, v)
                    
                    self.send_header('Content-Length', str(len(data)))
                    self.end_headers()
                    self.wfile.write(data)
            except urllib.error.HTTPError as e:
                self.send_response(e.code)
                data = e.read()
                for k, v in e.headers.items():
                    if k.lower() not in hop_by_hop and k.lower() != 'content-length':
                        self.send_header(k, v)
                self.send_header('Content-Length', str(len(data)))
                self.end_headers()
                self.wfile.write(data)
            except Exception as e:
                self.send_error(502, f"Proxy error: {str(e)}")
        else:
            # Serve static files as usual
            # SPA fallback: if the path is not a file, fallback to index.html
            local_path = self.translate_path(self.path)
            if not os.path.isfile(local_path):
                self.path = '/index.html'
            super().do_GET()

    def do_GET(self):
        self.do_request()

    def do_POST(self):
        self.do_request()

    def do_PUT(self):
        self.do_request()

    def do_DELETE(self):
        self.do_request()

    def do_OPTIONS(self):
        self.do_request()

if __name__ == '__main__':
    # Change directory to compiled web folder so SimpleHTTPRequestHandler serves files from there
    if os.path.exists(WEB_DIR):
        os.chdir(WEB_DIR)
        print(f"Changed working directory to {WEB_DIR}")
    else:
        print(f"Warning: {WEB_DIR} does not exist. Please run 'flutter build web' first.")
        
    port = int(sys.argv[1]) if len(sys.argv) > 1 else PORT
    server_address = ('', port)
    httpd = http.server.HTTPServer(server_address, ProxyHTTPRequestHandler)
    print(f"Server running on port {port}")
    print(f"Serving static files from: {WEB_DIR}")
    print(f"Routing API/Asset requests to backend at: {BACKEND_URL}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nExiting.")
