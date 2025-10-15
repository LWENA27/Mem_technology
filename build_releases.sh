#!/bin/bash

# Multi-Platform Build Script for LwenaTech Inventory Management
# This script builds executable installers for all major platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project info
APP_NAME="LwenaTech Inventory"
VERSION="1.0.0"
BUILD_DIR="releases"
WEB_DIR="web_build"

echo -e "${BLUE}🚀 LwenaTech Multi-Platform Build System${NC}"
echo -e "${BLUE}===============================================${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf build/
rm -rf $BUILD_DIR/
rm -rf $WEB_DIR/
mkdir -p $BUILD_DIR
mkdir -p $WEB_DIR

# Get dependencies
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
flutter pub get

# Function to build Windows executable
build_windows() {
    echo -e "${BLUE}🪟 Building Windows executable...${NC}"
    flutter build windows --release
    
    # Create Windows installer directory
    WIN_DIR="$BUILD_DIR/windows"
    mkdir -p "$WIN_DIR"
    
    # Copy Windows build
    cp -r build/windows/x64/runner/Release/* "$WIN_DIR/"
    
    # Create Windows installer script
    cat > "$WIN_DIR/install.bat" << 'EOF'
@echo off
    echo Installing LwenaTech Inventory Management System...
echo.
echo This will install the application to your Program Files.
echo Please run as Administrator if needed.
echo.
pause

    set "INSTALL_DIR=%ProgramFiles%\LwenaTech"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo Copying files...
xcopy /E /I /Y "%~dp0*" "%INSTALL_DIR%"

echo Creating desktop shortcut...
    set "SHORTCUT=%USERPROFILE%\Desktop\LwenaTech Inventory.lnk"
    powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); $Shortcut.TargetPath = '%INSTALL_DIR%\\LwenaTech.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Save()"

echo.
echo Installation complete!
echo You can find the application on your desktop or in Start Menu.
pause
EOF
    
    # Create uninstaller
    cat > "$WIN_DIR/uninstall.bat" << 'EOF'
@echo off
    echo Uninstalling LwenaTech Inventory Management System...
    echo.
    set "INSTALL_DIR=%ProgramFiles%\LwenaTech"
    set "SHORTCUT=%USERPROFILE%\Desktop\LwenaTech Inventory.lnk"

if exist "%SHORTCUT%" del "%SHORTCUT%"
if exist "%INSTALL_DIR%" rmdir /S /Q "%INSTALL_DIR%"

echo Uninstallation complete!
pause
EOF

    # Create README for Windows
    cat > "$WIN_DIR/README.txt" << EOF
LwenaTech Inventory Management System - Windows Edition
=========================================================

INSTALLATION:
1. Right-click on install.bat and select "Run as Administrator"
2. Follow the installation prompts
3. Launch from desktop shortcut or Start Menu

SYSTEM REQUIREMENTS:
- Windows 10 or later
- 4GB RAM minimum
- 100MB free disk space

FEATURES:
- Complete inventory management
- Multi-tenant support
- Real-time sync with cloud
- PDF reporting
- Image support for products

For support, visit: https://github.com/LWENA27/Mem_technology

Version: $VERSION
Build Date: $(date)
EOF

    # Create ZIP for Windows
    cd $BUILD_DIR
    zip -r "LwenaTech-Windows-v$VERSION.zip" windows/
    cd ..
    
    echo -e "${GREEN}✅ Windows build complete: $BUILD_DIR/LwenaTech-Windows-v$VERSION.zip${NC}"
}

# Function to build Android APK
build_android() {
    echo -e "${BLUE}🤖 Building Android APK...${NC}"
    flutter build apk --release
    
    # Create Android directory
    ANDROID_DIR="$BUILD_DIR/android"
    mkdir -p "$ANDROID_DIR"
    
    # Copy APK
    cp build/app/outputs/flutter-apk/app-release.apk "$ANDROID_DIR/LwenaTech-v$VERSION.apk"
    
    # Create installation guide for Android
    cat > "$ANDROID_DIR/INSTALL_ANDROID.txt" << EOF
LwenaTech Inventory Management System - Android Edition
=========================================================

INSTALLATION:
1. Download LwenaTech-v$VERSION.apk to your Android device
2. Enable "Install from Unknown Sources" in Settings > Security
3. Tap the APK file to install
4. Grant necessary permissions when prompted

SYSTEM REQUIREMENTS:
- Android 6.0 (API level 23) or later
- 2GB RAM minimum
- 50MB free storage space

FEATURES:
- Complete inventory management on mobile
- Camera integration for product photos
- Offline capability with cloud sync
- Touch-optimized interface

PERMISSIONS NEEDED:
- Camera: For taking product photos
- Storage: For saving images and data
- Internet: For cloud synchronization

For support, visit: https://github.com/LWENA27/Mem_technology

Version: $VERSION
Build Date: $(date)
EOF

    echo -e "${GREEN}✅ Android build complete: $ANDROID_DIR/LwenaTech-v$VERSION.apk${NC}"
}

# Function to build macOS app
build_macos() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${BLUE}🍎 Building macOS application...${NC}"
        flutter build macos --release
        
        # Create macOS directory
        MACOS_DIR="$BUILD_DIR/macos"
        mkdir -p "$MACOS_DIR"
        
        # Copy macOS app bundle
    cp -r build/macos/Build/Products/Release/lwenatech.app "$MACOS_DIR/"
        
    # Create DMG installer script (requires macOS)
    cat > "$MACOS_DIR/create_dmg.sh" << 'EOF'
#!/bin/bash
# Create DMG installer for macOS
hdiutil create -volname "LwenaTech Installer" -srcfolder lwenatech.app -ov -format UDZO LwenaTech-macOS.dmg
EOF
        chmod +x "$MACOS_DIR/create_dmg.sh"
        
    # Create installation guide
    cat > "$MACOS_DIR/INSTALL_MACOS.txt" << EOF
LwenaTech Inventory Management System - macOS Edition
=======================================================

INSTALLATION:
1. Download and mount the DMG file
2. Drag lwenatech.app to Applications folder
3. Launch from Applications or Launchpad

SYSTEM REQUIREMENTS:
- macOS 10.14 or later
- 4GB RAM minimum
- 100MB free disk space

Note: You may need to allow the app in System Preferences > Security & Privacy

Version: $VERSION
Build Date: $(date)
EOF

    # Create ZIP for macOS
    cd $BUILD_DIR
    zip -r "LwenaTech-macOS-v$VERSION.zip" macos/
    cd ..
        
    echo -e "${GREEN}✅ macOS build complete: $BUILD_DIR/LwenaTech-macOS-v$VERSION.zip${NC}"
    else
        echo -e "${YELLOW}⚠️  Skipping macOS build (not running on macOS)${NC}"
    fi
}

# Function to build Linux AppImage
build_linux() {
    echo -e "${BLUE}🐧 Building Linux application...${NC}"
    flutter build linux --release
    
    # Create Linux directory
    LINUX_DIR="$BUILD_DIR/linux"
    mkdir -p "$LINUX_DIR"
    
    # Copy Linux build
    cp -r build/linux/x64/release/bundle/* "$LINUX_DIR/"
    
    # Create Linux installer script
    cat > "$LINUX_DIR/install.sh" << 'EOF'
#!/bin/bash

APP_NAME="LwenaTech Inventory"
INSTALL_DIR="$HOME/.local/share/lwenatech"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "Installing $APP_NAME..."

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"

# Copy application files
cp -r ./* "$INSTALL_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/lwenatech"

# Create symlink in bin
ln -sf "$INSTALL_DIR/lwenatech" "$BIN_DIR/lwenatech"

# Create desktop entry
cat > "$DESKTOP_DIR/lwenatech.desktop" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=LwenaTech Inventory
Comment=Inventory Management System
Exec=$INSTALL_DIR/lwenatech
Icon=$INSTALL_DIR/data/flutter_assets/assets/app_icon.png
Terminal=false
Categories=Office;
EOL

echo "Installation complete!"
echo "You can launch the app from your application menu or run 'lwenatech' in terminal."
EOF
    chmod +x "$LINUX_DIR/install.sh"
    
        # Create uninstaller
        cat > "$LINUX_DIR/uninstall.sh" << 'EOF'
    #!/bin/bash

    APP_NAME="LwenaTech Inventory"
    INSTALL_DIR="$HOME/.local/share/lwenatech"
    BIN_DIR="$HOME/.local/bin"
    DESKTOP_DIR="$HOME/.local/share/applications"

    echo "Uninstalling $APP_NAME..."

    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_DIR/lwenatech"
    rm -f "$DESKTOP_DIR/lwenatech.desktop"

    echo "Uninstallation complete!"
    EOF
        chmod +x "$LINUX_DIR/uninstall.sh"
    
    # Create installation guide
    cat > "$LINUX_DIR/INSTALL_LINUX.txt" << EOF
LwenaTech Inventory Management System - Linux Edition
========================================================

INSTALLATION:
1. Extract the downloaded ZIP file
2. Open terminal in the extracted folder
3. Run: chmod +x install.sh && ./install.sh
4. Launch from application menu or run 'lwenatech' in terminal

SYSTEM REQUIREMENTS:
- Linux (Ubuntu 18.04+ or equivalent)
- 4GB RAM minimum
- 100MB free disk space
- GTK 3.0+

DEPENDENCIES:
If you encounter issues, install these packages:
- Ubuntu/Debian: sudo apt install libgtk-3-0 libblkid1 liblzma5
- Fedora: sudo dnf install gtk3 util-linux-libs xz-libs
- Arch: sudo pacman -S gtk3 util-linux xz

Version: $VERSION
Build Date: $(date)
EOF

    # Create TAR.GZ for Linux
    cd $BUILD_DIR
    tar -czf "LwenaTech-Linux-v$VERSION.tar.gz" linux/
    cd ..
    
    echo -e "${GREEN}✅ Linux build complete: $BUILD_DIR/LwenaTech-Linux-v$VERSION.tar.gz${NC}"
}

# Function to build Web version
build_web() {
    echo -e "${BLUE}🌐 Building Web application...${NC}"
    flutter build web --release --base-href "/"
    
    # Copy web build to dedicated directory
    cp -r build/web/* $WEB_DIR/
    
    # Create web deployment guide
    cat > "$WEB_DIR/DEPLOY_WEB.txt" << EOF
LwenaTech Inventory Management System - Web Edition
=====================================================

DEPLOYMENT:
This folder contains the complete web application ready for deployment.

HOSTING OPTIONS:
1. Static hosting (Netlify, Vercel, GitHub Pages)
2. Web server (Apache, Nginx)
3. Cloud platforms (Firebase Hosting, AWS S3)

REQUIREMENTS:
- HTTPS required for camera features
- Modern web browser (Chrome 80+, Firefox 75+, Safari 13+)

TO DEPLOY:
1. Upload all files in this directory to your web server
2. Configure your server to serve index.html for all routes
3. Ensure HTTPS is enabled

FEATURES:
- Progressive Web App (PWA)
- Offline capability
- Camera integration (HTTPS required)
- Real-time cloud sync

Version: $VERSION
Build Date: $(date)
EOF

    # Create ZIP for web
    cd $WEB_DIR
    zip -r "../$BUILD_DIR/LwenaTech-Web-v$VERSION.zip" .
    cd ..
    
    echo -e "${GREEN}✅ Web build complete: $BUILD_DIR/LwenaTech-Web-v$VERSION.zip${NC}"
}

# Main build process
echo -e "${YELLOW}🏗️  Starting multi-platform builds...${NC}"

# Build for all platforms
build_web
build_android
build_windows

# Build macOS if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    build_macos
fi

# Build Linux if on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    build_linux
fi

# Create master README
cat > "$BUILD_DIR/README.txt" << EOF
LwenaTech Inventory Management System
=======================================

Multi-Platform Release Package
Version: $VERSION
Build Date: $(date)

AVAILABLE PLATFORMS:
- Windows: LwenaTech-Windows-v$VERSION.zip
- Android: android/LwenaTech-v$VERSION.apk  
- Web: LwenaTech-Web-v$VERSION.zip
- Linux: LwenaTech-Linux-v$VERSION.tar.gz (if built on Linux)
- macOS: LwenaTech-macOS-v$VERSION.zip (if built on macOS)

QUICK START:
1. Choose your platform from the downloads above
2. Follow the installation instructions in each package
3. Launch the application and create your account
4. Start managing your inventory!

FEATURES:
✅ Multi-tenant inventory management
✅ Real-time cloud synchronization  
✅ Image support for products
✅ PDF reporting and exports
✅ Category and supplier management
✅ Stock tracking and alerts
✅ Responsive design for all devices

SUPPORT:
- Documentation: https://github.com/LWENA27/Mem_technology
- Issues: https://github.com/LWENA27/Mem_technology/issues
- Web Demo: https://your-app-url.netlify.app

Built with Flutter & Supabase
© 2024 LwenaTech. All rights reserved.
EOF

# Show build summary
echo
echo -e "${GREEN}🎉 BUILD COMPLETE! 🎉${NC}"
echo -e "${GREEN}===================${NC}"
echo
echo -e "${BLUE}📁 All builds are in: $BUILD_DIR/${NC}"
ls -la $BUILD_DIR/
echo
echo -e "${YELLOW}📋 To deploy these files:${NC}"
echo -e "1. Upload the builds to your website's download section"
echo -e "2. Update your settings page to link to these files"
echo -e "3. Users can download and install on their preferred platform"
echo
echo -e "${GREEN}✨ Your app is now ready for distribution! ✨${NC}"