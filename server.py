from http.server import HTTPServer, BaseHTTPRequestHandler
import os
import json
GITHUB_SECRET = os.environ.get("GITHUB_SECRET")
#second try

class GitHubWebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get('Content-Length'))
        payload = self.rfile.read(length)

        if GITHUB_SECRET:
            signature = self.headers.get('X-Hub-Signature-256')
            if not signature:
                self.send_error(400, "Missing signature")
                return

            sha_name, sig_hash = signature.split('=')
            if sha_name != 'sha256':
                self.send_error(400, "Unsupported signature type")
                return

            mac = hmac.new(GITHUB_SECRET, msg=payload, digestmod=hashlib.sha256)
            if not hmac.compare_digest(mac.hexdigest(), sig_hash):
                self.send_error(403, "Invalid signature")
                return

        try:
            data = json.loads(payload.decode())
            print("Received webhook for:", data.get("repository", {}).get("full_name", "unknown repo"))
        except json.JSONDecodeError:
            self.send_error(400, "Invalid JSON")
            return
        
        #Respond is OK - 200
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Webhook received")


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 3000), GitHubWebhookHandler)
    server.serve_forever()