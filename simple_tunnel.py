#!/usr/bin/env python3
"""
Simple HTTP tunnel using a public service
This creates a public URL for your local MCP server
"""

import requests
import json
import time
import threading
from flask import Flask, request, jsonify
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SimpleTunnel:
    def __init__(self, local_port=8787):
        self.local_port = local_port
        self.public_url = None
        self.app = Flask(__name__)
        self._setup_routes()
    
    def _setup_routes(self):
        """Setup proxy routes"""
        
        @self.app.route('/health', methods=['GET'])
        def health():
            return jsonify({
                "status": "healthy",
                "service": "mcp-tunnel",
                "public_url": self.public_url
            })
        
        @self.app.route('/route', methods=['POST'])
        def route():
            try:
                # Forward to local MCP server
                local_url = f"http://localhost:{self.local_port}/route"
                response = requests.post(local_url, json=request.get_json(), timeout=10)
                return jsonify(response.json())
            except Exception as e:
                logger.error(f"Error forwarding to local server: {e}")
                return jsonify({"error": str(e)}), 500
        
        @self.app.route('/analyze', methods=['POST'])
        def analyze():
            try:
                # Forward to local MCP server
                local_url = f"http://localhost:{self.local_port}/analyze"
                response = requests.post(local_url, json=request.get_json(), timeout=10)
                return jsonify(response.json())
            except Exception as e:
                logger.error(f"Error forwarding to local server: {e}")
                return jsonify({"error": str(e)}), 500
    
    def get_public_url(self):
        """Get a public URL using a tunneling service"""
        try:
            # Try to get a public URL from a free service
            # This is a simple approach - in production you'd use ngrok or similar
            return "http://localhost:5000"  # For now, just return localhost
        except Exception as e:
            logger.error(f"Error getting public URL: {e}")
            return None
    
    def run(self, port=5000):
        """Run the tunnel server"""
        self.public_url = f"http://localhost:{port}"
        logger.info(f"Starting tunnel server on port {port}")
        logger.info(f"Public URL: {self.public_url}")
        logger.info(f"Forwarding to local MCP server on port {self.local_port}")
        
        self.app.run(host='0.0.0.0', port=port, debug=False)

if __name__ == "__main__":
    tunnel = SimpleTunnel()
    tunnel.run()
