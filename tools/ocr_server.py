#!/usr/bin/env python3
"""
ZRPD_EDEV OCR Server — Flask REST API for PDF text extraction.

Usage:
  source .venv/bin/activate
  python3 tools/ocr_server.py [--port 5000] [--host 0.0.0.0]

Endpoints:
  GET  /health   — Server status
  POST /extract  — PDF OCR extraction
    Input:  {"pdf_base64": "<base64 encoded PDF>"}
    Output: {"tckn": "...", "barcode": "...", "full_name": "...", ...}
"""

import base64
import time
import argparse
import os
import sys
from flask import Flask, request, jsonify

# Ensure tools/ directory is in path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ocr_extract import extract_text_from_bytes, parse_ikametgah

app = Flask(__name__)


@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "service": "ZRPD_EDEV_OCR"}), 200


@app.route('/extract', methods=['POST'])
def extract():
    start = time.time()

    data = request.get_json(silent=True)
    if not data or 'pdf_base64' not in data:
        return jsonify({"error": "Missing pdf_base64 field"}), 400

    try:
        pdf_bytes = base64.b64decode(data['pdf_base64'])
    except Exception as e:
        return jsonify({"error": f"Base64 decode failed: {str(e)}"}), 400

    if len(pdf_bytes) < 100:
        return jsonify({"error": "PDF too small"}), 400

    try:
        text = extract_text_from_bytes(pdf_bytes)
    except Exception as e:
        return jsonify({"error": f"OCR failed: {str(e)}"}), 500

    if not text or not text.strip():
        return jsonify({"error": "No text extracted from PDF"}), 422

    result = parse_ikametgah(text)
    result['ocr_text_length'] = len(text)
    result['processing_ms'] = int((time.time() - start) * 1000)

    return jsonify(result), 200


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='EDEV OCR Server')
    parser.add_argument('--port', type=int, default=8090)
    parser.add_argument('--host', type=str, default='0.0.0.0')
    args = parser.parse_args()

    print(f"EDEV OCR Server starting on {args.host}:{args.port}")
    app.run(host=args.host, port=args.port, debug=False)
