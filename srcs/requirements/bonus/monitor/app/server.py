#!/usr/bin/env python3

import html
import os
import platform
import socket
import time
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


START_TIME = time.monotonic()


class MonitorHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path not in ("/", "/health"):
            self.send_error(404)
            return

        if self.path == "/health":
            body = b"OK\n"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return

        uptime = int(time.monotonic() - START_TIME)
        hostname = html.escape(socket.gethostname())
        system = html.escape(
            f"{platform.system()} {platform.release()}"
        )
        current_time = datetime.now(timezone.utc).strftime(
            "%Y-%m-%d %H:%M:%S UTC"
        )

        page = f"""<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inception Monitor</title>
    <style>
        body {{
            max-width: 700px;
            margin: 60px auto;
            padding: 20px;
            font-family: sans-serif;
            color: #263238;
            background: #eef5f2;
        }}
        main {{
            padding: 30px;
            border-radius: 12px;
            background: white;
            box-shadow: 0 8px 24px #0002;
        }}
        dt {{
            margin-top: 16px;
            font-weight: bold;
        }}
        dd {{
            margin: 4px 0;
        }}
        .status {{
            color: #16813b;
            font-weight: bold;
        }}
    </style>
</head>
<body>
    <main>
        <h1>Inception Monitor</h1>
        <p class="status">Service is running</p>
        <dl>
            <dt>Container hostname</dt>
            <dd>{hostname}</dd>
            <dt>Operating system</dt>
            <dd>{system}</dd>
            <dt>Current time</dt>
            <dd>{current_time}</dd>
            <dt>Service uptime</dt>
            <dd>{uptime} seconds</dd>
        </dl>
    </main>
</body>
</html>
"""

        body = page.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, message_format, *args):
        print(
            f"{self.client_address[0]} - "
            f"{message_format % args}",
            flush=True,
        )


if __name__ == "__main__":
    port = int(os.environ.get("MONITOR_PORT", "8090"))
    server = ThreadingHTTPServer(("0.0.0.0", port), MonitorHandler)

    print(f"Monitor listening on port {port}", flush=True)
    server.serve_forever()
