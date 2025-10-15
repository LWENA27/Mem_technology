#!/bin/bash

# InventoryMaster SaaS - Multi-Platform Build Script
# This script builds the application for all supported platforms

set -e

echo "🚀 InventoryMaster SaaS - Multi-Platform Build System"
echo "=================================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter could not be found. Please install Flutter first."
    exit 1
fi

# Function to check platform availability
check_platform() {
    local platform=$1
    if flutter config | grep -q "$platform: enabled"; then
        return 0
    else
        return 1
    fi
}

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local script=$2
    
    echo ""
    echo "🏗️ Building for $platform..."
    echo "================================"
    
    if [ -f "$script" ]; then
        chmod +x "$script"
        bash "$script"
    else
        echo "❌ Build script not found: $script"
        return 1
    fi
}

# Create main installer directory
MAIN_INSTALLER_DIR="build/installer"
mkdir -p "$MAIN_INSTALLER_DIR"

# Build counter
BUILD_COUNT=0
SUCCESSFUL_BUILDS=()
FAILED_BUILDS=()

echo "📋 Available Platforms:"
echo "  1. Web (always available)"
echo "  2. Android (APK)"

# Check for desktop platforms
if check_platform "windows-desktop"; then
    echo "  3. Windows Desktop"
fi

if check_platform "macos-desktop"; then
    echo "  4. macOS Desktop"
fi

if check_platform "linux-desktop"; then
    echo "  5. Linux Desktop"
fi

echo ""
read -p "🤔 Build for all available platforms? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BUILD_ALL=true
else
    BUILD_ALL=false
    echo "Available options:"
    echo "1) Web only"
    echo "2) Android only"
    echo "3) Windows only (if available)"
    echo "4) Custom selection"
    read -p "Choose option (1-4): " OPTION
fi

# Build Web (always available)
if [ "$BUILD_ALL" = true ] || [ "$OPTION" = "1" ] || [ "$OPTION" = "4" ]; then
    echo ""
    echo "🌐 Building Web Application..."
    echo "============================="
    
    flutter clean
    flutter pub get
    
    # Set environment variables for production build
    export SUPABASE_URL="${SUPABASE_URL:-https://your-project.supabase.co}"
    export SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-your-anon-key}"
    
    if flutter build web --release; then
        BUILD_COUNT=$((BUILD_COUNT + 1))
        SUCCESSFUL_BUILDS+=("Web")
        
        # Create web installer package
        WEB_DIR="$MAIN_INSTALLER_DIR/web"
        mkdir -p "$WEB_DIR"
        cp -r build/web/* "$WEB_DIR/"
        
        # Create web deployment guide
        cat > "$WEB_DIR/DEPLOYMENT_GUIDE.txt" << 'EOF'
InventoryMaster SaaS - Web Deployment Guide

HOSTING REQUIREMENTS:
- Static web hosting (Netlify, Vercel, Firebase Hosting, etc.)
- HTTPS support required
- Custom domain support (recommended)

DEPLOYMENT STEPS:

1. NETLIFY DEPLOYMENT:
   - Connect your GitHub repository to Netlify
   - Set build command: ./build.sh
   - Set publish directory: build/web
   - Add environment variables: SUPABASE_URL, SUPABASE_ANON_KEY

2. VERCEL DEPLOYMENT:
   - Install Vercel CLI: npm i -g vercel
   - Run: vercel --prod
   - Set build output directory: build/web

3. FIREBASE HOSTING:
   - Install Firebase CLI: npm install -g firebase-tools
   - Initialize: firebase init hosting
   - Set public directory: build/web
   - Deploy: firebase deploy

4. CUSTOM SERVER:
   - Upload all files from build/web to your web server
   - Configure server to serve index.html for all routes
   - Ensure HTTPS is enabled

ENVIRONMENT VARIABLES:
- SUPABASE_URL: Your Supabase project URL
- SUPABASE_ANON_KEY: Your Supabase anonymous key

FEATURES:
- Responsive design for all screen sizes
- Progressive Web App (PWA) capabilities
- Offline support for cached data
- Real-time synchronization
- Cross-platform compatibility

© 2025 MEM Technology. All rights reserved.
EOF
        
        echo "✅ Web build completed: $WEB_DIR"
    else
        FAILED_BUILDS+=("Web")
        echo "❌ Web build failed"
    fi
fi

# Build Android
if [ "$BUILD_ALL" = true ] || [ "$OPTION" = "2" ] || [ "$OPTION" = "4" ]; then
    if build_platform "Android" "build_android.sh"; then
        BUILD_COUNT=$((BUILD_COUNT + 1))
        SUCCESSFUL_BUILDS+=("Android")
    else
        FAILED_BUILDS+=("Android")
    fi
fi

# Build Windows
if ([ "$BUILD_ALL" = true ] || [ "$OPTION" = "3" ] || [ "$OPTION" = "4" ]) && check_platform "windows-desktop"; then
    if build_platform "Windows" "build_windows.sh"; then
        BUILD_COUNT=$((BUILD_COUNT + 1))
        SUCCESSFUL_BUILDS+=("Windows")
    else
        FAILED_BUILDS+=("Windows")
    fi
fi

# Create master README
cat > "$MAIN_INSTALLER_DIR/README.md" << EOF
# InventoryMaster SaaS - Installation Packages

Welcome to InventoryMaster SaaS, a comprehensive multi-tenant inventory management system built with Flutter and Supabase.

## Available Platforms

This package contains installation files for multiple platforms:

$(if [ -d "$MAIN_INSTALLER_DIR/web" ]; then echo "- **Web Application**: Deploy to any web hosting service"; fi)
$(if [ -d "$MAIN_INSTALLER_DIR/android" ]; then echo "- **Android Mobile**: APK files for Android 5.0+"; fi)
$(if [ -d "$MAIN_INSTALLER_DIR/windows" ]; then echo "- **Windows Desktop**: Executable for Windows 10/11"; fi)

## Quick Start

1. Choose your platform from the available folders
2. Follow the installation guide in each platform's directory
3. Configure your Supabase credentials for full functionality

## System Requirements

### Minimum Requirements
- **Web**: Modern browser with JavaScript enabled
- **Android**: Android 5.0+ (API 21), 2GB RAM, 100MB storage
- **Windows**: Windows 10/11 (64-bit), 4GB RAM, 1GB storage

### Recommended Requirements
- **All Platforms**: Stable internet connection for real-time sync
- **All Platforms**: 4GB+ RAM for optimal performance

## Features

- ✅ Multi-tenant inventory management
- ✅ Product catalog with up to 5 images per product
- ✅ Sales tracking and reporting
- ✅ Real-time data synchronization
- ✅ Cross-platform compatibility
- ✅ Offline viewing capabilities
- ✅ User authentication and access control
- ✅ Export functionality for reports

## Configuration

Before using the application, ensure you have:
1. A Supabase project set up
2. Proper database schema configured
3. Storage bucket for images configured
4. Environment variables set (for web deployment)

## Support

- **GitHub Repository**: https://github.com/LWENA27/Mem_technology
- **Issues & Bug Reports**: https://github.com/LWENA27/Mem_technology/issues
- **Email Support**: support@lwenatech.com

## License

© 2025 LwenaTech. All rights reserved.

---

*Built with ❤️ using Flutter & Supabase*
EOF

# Summary
echo ""
echo "🎉 Build Summary"
echo "================"
echo "Total builds attempted: $((${#SUCCESSFUL_BUILDS[@]} + ${#FAILED_BUILDS[@]}))"
echo "Successful builds: ${#SUCCESSFUL_BUILDS[@]}"
echo "Failed builds: ${#FAILED_BUILDS[@]}"

if [ ${#SUCCESSFUL_BUILDS[@]} -gt 0 ]; then
    echo ""
    echo "✅ Successfully built for:"
    for platform in "${SUCCESSFUL_BUILDS[@]}"; do
        echo "  - $platform"
    done
fi

if [ ${#FAILED_BUILDS[@]} -gt 0 ]; then
    echo ""
    echo "❌ Failed builds:"
    for platform in "${FAILED_BUILDS[@]}"; do
        echo "  - $platform"
    done
fi

echo ""
echo "📦 Installation packages available at: $MAIN_INSTALLER_DIR"
echo "📚 Documentation included in each platform directory"

if [ ${#SUCCESSFUL_BUILDS[@]} -gt 0 ]; then
    echo ""
    echo "🚀 Ready for distribution!"
    echo "Upload the contents of '$MAIN_INSTALLER_DIR' to your preferred hosting service."
else
    echo ""
    echo "⚠️ No successful builds. Please check the error messages above."
    exit 1
fi