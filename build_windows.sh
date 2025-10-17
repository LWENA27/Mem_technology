#!/bin/bash

# InventoryMaster SaaS - Windows Build Script
# This script builds the Windows desktop application

set -e

echo "🚀 Building InventoryMaster SaaS for Windows..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter could not be found. Please install Flutter first."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Enable Windows desktop support if not already enabled
echo "🖥️ Ensuring Windows desktop support is enabled..."
flutter config --enable-windows-desktop

# Build for Windows
echo "🏗️ Building Windows application..."
flutter build windows --release

# Create build info
BUILD_DIR="build/windows/x64/runner/Release"
if [ -d "$BUILD_DIR" ]; then
    echo "✅ Windows build completed successfully!"
    echo "📍 Build location: $BUILD_DIR"
    
    # Create a simple installer structure
    INSTALLER_DIR="build/installer/windows"
    mkdir -p "$INSTALLER_DIR"
    
    # Copy the entire Release folder
    cp -r "$BUILD_DIR"/* "$INSTALLER_DIR/"
    
    # Create a simple batch file for easy launching
    cat > "$INSTALLER_DIR/run.bat" << 'EOF'
@echo off
echo Starting InventoryMaster SaaS...
start lwenatech.exe
EOF
    
    # Create README for Windows users
    cat > "$INSTALLER_DIR/README.txt" << 'EOF'
InventoryMaster SaaS - Windows Desktop Application

SYSTEM REQUIREMENTS:
- Windows 10 or Windows 11 (64-bit)
- 4GB RAM minimum
- 1GB free disk space
- Internet connection for full functionality

INSTALLATION:
1. Extract all files to a folder (e.g., C:\Program Files\InventoryMaster)
2. Double-click lwenatech.exe to run the application
   OR
   Double-click run.bat for convenient launching

FEATURES:
- Multi-tenant inventory management
- Product image management (up to 5 images per product)
- Sales tracking and reporting
- Real-time data synchronization
- Cross-platform compatibility

SUPPORT:
For technical support, visit: https://github.com/LWENA27/Mem_technology
Email: support@lwenatech.com

© 2025 Lwena Tech. All rights reserved.
EOF

    echo "📦 Created installer package at: $INSTALLER_DIR"
    echo "💾 File size: $(du -sh "$INSTALLER_DIR" | cut -f1)"
    
else
    echo "❌ Build failed! Check the output above for errors."
    exit 1
fi

echo "🎉 Windows build process completed!"