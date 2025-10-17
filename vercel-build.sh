#!/bin/bash

# Vercel Flutter Build Script for LwenaTech Inventory Management
set -e

echo "🚀 LwenaTech Flutter Build on Vercel"
echo "===================================="

# Install Flutter
echo "📦 Installing Flutter..."
cd /tmp
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="/tmp/flutter/bin:$PATH"

# Verify Flutter installation
flutter --version

# Go back to project directory
cd $VERCEL_PROJECT_DIR

# Get dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Enable web
echo "🌐 Enabling Flutter web..."
flutter config --enable-web

# Build for web
echo "🏗️ Building Flutter web app..."
flutter build web --release

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web"