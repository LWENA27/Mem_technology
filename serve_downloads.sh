#!/bin/bash

# Simple HTTP server to test downloads locally
# This serves the downloads at http://localhost:8080/downloads/

echo "🌐 Starting local downloads server..."
echo "📂 Serving downloads from: web/downloads/"
echo "🔗 Access downloads at: http://localhost:8080/downloads/"
echo "📱 Android APK: http://localhost:8080/downloads/android/LwenaTech-v1.0.0.apk"
echo "🌐 Web Package: http://localhost:8080/downloads/LwenaTech-Web-v1.0.0.zip"
echo ""
echo "Press Ctrl+C to stop the server"
echo "============================================"

cd web && python3 -m http.server 8080