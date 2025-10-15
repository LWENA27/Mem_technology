#!/bin/bash

# InventoryMaster SaaS - Android Build Script
# This script builds the Android APK

set -e

echo "🚀 Building InventoryMaster SaaS for Android..."

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

# Build APK
echo "🏗️ Building Android APK..."
flutter build apk --release --split-per-abi

# Also build a universal APK for broader compatibility
echo "🏗️ Building universal Android APK..."
flutter build apk --release

# Create build info
APK_DIR="build/app/outputs/flutter-apk"
INSTALLER_DIR="build/installer/android"

if [ -d "$APK_DIR" ]; then
    echo "✅ Android build completed successfully!"
    echo "📍 APK location: $APK_DIR"
    
    # Create installer directory
    mkdir -p "$INSTALLER_DIR"
    
    # Copy APKs with better names
    if [ -f "$APK_DIR/app-release.apk" ]; then
        cp "$APK_DIR/app-release.apk" "$INSTALLER_DIR/inventorymaster-universal.apk"
        echo "📱 Universal APK: $INSTALLER_DIR/inventorymaster-universal.apk"
    fi
    
    # Copy architecture-specific APKs if they exist
    if [ -f "$APK_DIR/app-arm64-v8a-release.apk" ]; then
        cp "$APK_DIR/app-arm64-v8a-release.apk" "$INSTALLER_DIR/inventorymaster-arm64.apk"
        echo "📱 ARM64 APK: $INSTALLER_DIR/inventorymaster-arm64.apk"
    fi
    
    if [ -f "$APK_DIR/app-armeabi-v7a-release.apk" ]; then
        cp "$APK_DIR/app-armeabi-v7a-release.apk" "$INSTALLER_DIR/inventorymaster-arm32.apk"
        echo "📱 ARM32 APK: $INSTALLER_DIR/inventorymaster-arm32.apk"
    fi
    
    if [ -f "$APK_DIR/app-x86_64-release.apk" ]; then
        cp "$APK_DIR/app-x86_64-release.apk" "$INSTALLER_DIR/inventorymaster-x86_64.apk"
        echo "📱 x86_64 APK: $INSTALLER_DIR/inventorymaster-x86_64.apk"
    fi
    
    # Create installation guide for Android
    cat > "$INSTALLER_DIR/INSTALLATION_GUIDE.txt" << 'EOF'
InventoryMaster SaaS - Android Installation Guide

SYSTEM REQUIREMENTS:
- Android 5.0+ (API level 21 or higher)
- 2GB RAM minimum
- 100MB free storage
- Internet connection for full functionality

APK FILES:
- inventorymaster-universal.apk: Works on all Android devices (recommended)
- inventorymaster-arm64.apk: Optimized for 64-bit ARM processors (newer phones)
- inventorymaster-arm32.apk: For 32-bit ARM processors (older phones)
- inventorymaster-x86_64.apk: For Intel/AMD processors (rare on mobile)

INSTALLATION STEPS:
1. Transfer the APK file to your Android device
2. Enable "Install from Unknown Sources" in your device settings:
   - Go to Settings > Security > Unknown Sources (Android 7 and below)
   - OR Settings > Apps & Notifications > Advanced > Special App Access > Install Unknown Apps (Android 8+)
3. Locate the APK file using a file manager
4. Tap the APK file to begin installation
5. Follow the on-screen prompts
6. Launch "InventoryMaster SaaS" from your app drawer

CHOOSING THE RIGHT APK:
- If unsure, use the universal APK (inventorymaster-universal.apk)
- For better performance, use the architecture-specific APK for your device
- Most modern phones (2018+) use ARM64 architecture

TROUBLESHOOTING:
- If installation fails, ensure you have enough storage space
- Some devices may require enabling "Install from Unknown Sources" for each app
- If the app crashes, try the universal APK instead of architecture-specific ones

FEATURES:
- Complete inventory management system
- Multi-image product support
- Real-time synchronization
- Offline capability for viewing products
- Cross-platform data compatibility

SUPPORT:
GitHub: https://github.com/LWENA27/Mem_technology
Email: support@lwenatech.com

© 2025 MEM Technology. All rights reserved.
EOF
    
    # Show file sizes
    echo ""
    echo "📊 APK File Sizes:"
    find "$INSTALLER_DIR" -name "*.apk" -exec ls -lh {} \; | awk '{print $9 ": " $5}'
    
else
    echo "❌ Build failed! Check the output above for errors."
    exit 1
fi

echo "🎉 Android build process completed!"