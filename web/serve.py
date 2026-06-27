#!/usr/bin/env python3
"""Static server for Chasm web testing."""
import http.server
import os
import socketserver

PORT = int(os.environ.get('CHASM_PORT', '8771'))

class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **getattr(http.server.SimpleHTTPRequestHandler, 'extensions_map', {}),
        '.js': 'application/javascript',
        '.wasm': 'application/wasm',
        '.data': 'application/octet-stream',
    }

    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

os.chdir(os.path.dirname(os.path.abspath(__file__)))
with socketserver.TCPServer(('', PORT), Handler) as httpd:
    print(f'Chasm web: http://127.0.0.1:{PORT}/run.html')
    httpd.serve_forever()
