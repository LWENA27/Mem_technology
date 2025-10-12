#!/bin/bash

# InventoryMaster SaaS - Netlify Build Script
# This script handles Flutter installation and web build for Netlify

set -e  # Exit on any error

echo "🚀 Starting InventoryMaster SaaS Build Process..."

# Check if we're in Netlify environment
if [ -n "$NETLIFY" ]; then
    echo "📦 Detected Netlify environment"
    
    # Install Flutter
    echo "📥 Downloading Flutter SDK..."
    wget -q -O flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz
    
    echo "📂 Extracting Flutter..."
    tar xf flutter.tar.xz
    
    # Add Flutter to PATH
    export PATH="$PWD/flutter/bin:$PATH"
    
    echo "✅ Flutter installed successfully"
else
    echo "🏠 Local development environment detected"
fi

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version

# Enable web support
echo "🌐 Enabling Flutter web support..."
flutter config --enable-web --no-analytics

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Check for environment variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "⚠️  Warning: SUPABASE_URL or SUPABASE_ANON_KEY not set"
    echo "🔧 Building with placeholder values..."
    export SUPABASE_URL="https://your-project.supabase.co"
    export SUPABASE_ANON_KEY="your-anon-key"
fi

# Build web app
echo "🏗️  Building web application..."
flutter build web --release \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web"

# List build output for debugging
echo "📋 Build output contents:"
ls -la build/web/