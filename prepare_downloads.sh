#!/bin/bash

# LwenaTech Downloads Preparation Script
# This script builds and prepares downloadable files for web hosting

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOWNLOADS_DIR="web/downloads"
VERSION="1.0.0"

echo -e "${BLUE}🚀 Preparing LwenaTech Downloads${NC}"
echo -e "${BLUE}================================${NC}"

echo -e "${BLUE}🚀 Preparing LwenaTech Downloads${NC}"
mkdir -p "$DOWNLOADS_DIR/android"
mkdir -p "$DOWNLOADS_DIR/web"
mkdir -p "$DOWNLOADS_DIR/docs"

# Build Android APK (if on Linux)
echo -e "${YELLOW}🤖 Building Android APK...${NC}"
flutter pub get
# Copy Android APK
cp build/app/outputs/flutter-apk/app-release.apk "$DOWNLOADS_DIR/android/LwenaTech-v$VERSION.apk"
# Create Android installation guide
cat > "$DOWNLOADS_DIR/android/INSTALL_ANDROID.txt" << EOF
LwenaTech Inventory Management System - Android Edition
=========================================================

INSTALLATION STEPS:
1. Download LwenaTech-v$VERSION.apk to your Android device
2. Go to Settings > Security > Install from Unknown Sources (enable)
3. Open your file manager and tap the APK file
4. Tap "Install" and grant necessary permissions
5. Launch the app from your app drawer
LwenaTech Inventory Management System - Web Edition
SYSTEM REQUIREMENTS:
✅ Android 6.0 (API level 23) or later
✅ 2GB RAM minimum (4GB recommended)
✅ 50MB free storage space
✅ Internet connection for cloud sync

FEATURES:
📱 Mobile-optimized inventory management
📷 Camera integration for product photos
LwenaTech is available on all major platforms. Choose your preferred installation method below:
🔒 Secure multi-tenant architecture
📊 Real-time reporting and analytics

PERMISSIONS REQUIRED:
📷 Camera: For taking product photos
💾 Storage: For saving images and app data
🌐 Internet: For cloud synchronization
📍 Location: For warehouse location tracking (optional)

TROUBLESHOOTING:
- If installation is blocked, enable "Install from Unknown Sources"
- Clear app data if experiencing sync issues
- Restart device if app doesn't appear after installation

    Support: https://github.com/LWENA27/Mem_technology/issues
Version: $VERSION
Build Date: $(date)
EOF

# Build Web version
echo -e "${YELLOW}🌐 Building Web application...${NC}"
flutter build web --release --base-href "/"

# Create web deployment package
cp -r build/web/* "$DOWNLOADS_DIR/web/"

# Create web deployment guide
cat > "$DOWNLOADS_DIR/web/DEPLOY_WEB.txt" << EOF
LwenaTech Inventory Management System - Web Edition
=====================================================

DEPLOYMENT GUIDE:

QUICK DEPLOY (Recommended):
1. Upload all files to your web hosting service
2. Configure your server to serve index.html for all routes
3. Ensure HTTPS is enabled (required for camera features)
4. Access your deployed app via your domain

HOSTING OPTIONS:

📡 Static Hosting Services:
   • Netlify: Drag & drop this folder to netlify.com/drop
   • Vercel: Import from GitHub or upload folder
   • GitHub Pages: Push to gh-pages branch
   • Firebase Hosting: firebase deploy
   • AWS S3: Upload with static website hosting

🖥️ Traditional Web Servers:
   • Apache: Place files in document root, configure routing
   • Nginx: Configure try_files directive for SPA routing
   • IIS: Configure URL rewrite rules

SERVER CONFIGURATION:
For proper routing, configure your server to serve index.html for all routes:

Apache (.htaccess):
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]

Nginx:
location / {
    try_files \$uri \$uri/ /index.html;
}

REQUIREMENTS:
✅ Modern web browser (Chrome 80+, Firefox 75+, Safari 13+)
✅ HTTPS enabled (required for camera/microphone access)
✅ Internet connection for backend services

FEATURES:
🌐 Progressive Web App (PWA) capabilities
📱 Responsive design for all devices
⚡ Fast loading with service worker caching
🔒 Secure authentication and data encryption
📊 Real-time inventory synchronization

Performance Tips:
- Enable gzip compression on your server
- Configure browser caching headers
- Use a CDN for better global performance

Version: $VERSION
Build Date: $(date)
EOF

# Create comprehensive installation guide
cat > "$DOWNLOADS_DIR/docs/INSTALLATION_GUIDE.md" << EOF
# LwenaTech Inventory Management System
## Complete Installation Guide

### 🚀 Quick Start

LwenaTech is available on all major platforms. Choose your preferred installation method below:

---

## 📱 Android Installation

### Requirements
- Android 6.0+ (API level 23)
- 2GB RAM (4GB recommended)
- 50MB storage space

### Installation Steps
1. **Download APK**: Get \`LwenaTech-v$VERSION.apk\` from our downloads
2. **Enable Unknown Sources**: 
   - Go to Settings → Security → Install from Unknown Sources
   - Toggle ON for your file manager or browser
3. **Install**: Tap the APK file and follow prompts
4. **Launch**: Find LwenaTech in your app drawer

### Troubleshooting
- **Installation blocked?** Enable "Install from Unknown Sources"
- **App crashes?** Restart device and ensure you have sufficient RAM
- **Sync issues?** Check internet connection and app permissions

---

## 🌐 Web Application

### For Users (Access Online)
Simply visit: **[your-domain.com](https://your-app-url.netlify.app)**
- No installation required
- Works in any modern browser
- Automatic updates

### For Administrators (Self-Hosting)
1. **Download**: Get \`LwenaTech-Web-v$VERSION.zip\`
2. **Extract**: Unzip to your web server directory
3. **Configure**: Set up server routing (see DEPLOY_WEB.txt)
4. **Enable HTTPS**: Required for camera features

**Supported Hosting:**
- Netlify (recommended)
- Vercel
- GitHub Pages
- Firebase Hosting
- AWS S3 + CloudFront
- Traditional web servers (Apache, Nginx)

---

## 🪟 Windows Desktop (Coming Soon)

### Requirements
- Windows 10 or later
- 4GB RAM minimum
- 1GB storage space

### Installation Steps
1. **Download**: Get \`LwenaTech-Windows-v$VERSION.zip\`
2. **Extract**: Unzip to a temporary folder
3. **Install**: Right-click \`install.bat\` → "Run as Administrator"
4. **Launch**: Use desktop shortcut or Start Menu

---

## 🍎 macOS Desktop (Coming Soon)

### Requirements
- macOS 10.14 or later
- 4GB RAM minimum
- 1GB storage space

### Installation Steps
1. **Download**: Get \`LwenaTech-macOS-v$VERSION.zip\`
2. **Extract**: Double-click to extract
3. **Install**: Drag LwenaTech.app to Applications folder
4. **Security**: Allow app in System Preferences → Security & Privacy
5. **Launch**: Find in Applications or Launchpad

---

## 🐧 Linux Desktop (Coming Soon)

### Requirements
- Ubuntu 18.04+ or equivalent
- 4GB RAM minimum
- 1GB storage space
- GTK 3.0+

### Installation Steps
1. **Download**: Get \`LwenaTech-Linux-v$VERSION.tar.gz\`
2. **Extract**: \`tar -xzf LwenaTech-Linux-v$VERSION.tar.gz\`
3. **Install**: \`cd extracted_folder && chmod +x install.sh && ./install.sh\`
4. **Launch**: Run `lwenatech` in terminal or find in applications

### Dependencies
If you encounter issues, install these packages:
\`\`\`bash
# Ubuntu/Debian
sudo apt install libgtk-3-0 libblkid1 liblzma5

# Fedora
sudo dnf install gtk3 util-linux-libs xz-libs

# Arch
sudo pacman -S gtk3 util-linux xz
\`\`\`

---

## ⚡ Features Overview

### Core Functionality
✅ **Multi-tenant Architecture**: Perfect for businesses and teams  
✅ **Inventory Management**: Products, categories, suppliers  
✅ **Real-time Sync**: Cloud-based with offline capability  
✅ **Image Support**: Product photos with camera integration  
✅ **PDF Reports**: Generate and export inventory reports  
✅ **Stock Tracking**: Low stock alerts and notifications  
✅ **User Management**: Role-based access control  

### Technical Features
✅ **Cross-platform**: Web, Android, Windows, macOS, Linux  
✅ **Modern UI**: Material Design with responsive layout  
✅ **PWA Support**: Install web app like native application  
✅ **Offline Mode**: Continue working without internet  
✅ **Data Security**: End-to-end encryption and secure authentication  

---

## 🆘 Support & Help

### Getting Started
1. **Create Account**: Sign up using the app or web interface
2. **Set up Company**: Configure your business information
3. **Add Products**: Start with a few test products
4. **Invite Team**: Add team members with appropriate roles
5. **Explore Features**: Try different modules and reports

### Documentation
- **User Guide**: Available in-app help section
- **API Documentation**: For developers and integrations
- **Video Tutorials**: Step-by-step guides (coming soon)

### Support Channels
- **GitHub Issues**: [Report bugs and feature requests](https://github.com/LWENA27/Mem_technology/issues)
-- **Email Support**: support@lwenatech.com
- **Community Forum**: [Coming soon]

### System Status
- **Service Status**: Check our status page for updates
- **Planned Maintenance**: Announced in advance
- **Update Notifications**: Automatic for web, manual for desktop/mobile

---

## 🔄 Updates & Versioning

### Web Application
- **Automatic Updates**: No action required
- **Cache Refresh**: Force refresh (Ctrl+F5) if issues occur

### Mobile & Desktop
- **Manual Updates**: Download new versions from our releases
- **Notification**: In-app notifications for new versions
- **Backup**: Your data is safely stored in the cloud

---

## 📞 Contact Information

**Lwena Tech**  
📧 Email: support@lwenatech.com  
🌐 Website: https://lwenatech.com  
💻 GitHub: https://github.com/LWENA27/Mem_technology  

Built with ❤️ using Flutter & Supabase  
© 2024Lwena Tech. All rights reserved.
EOF

# Create downloads index page
cat > "$DOWNLOADS_DIR/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LwenaTech Downloads</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: #4CAF50;
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        .content {
            padding: 40px 30px;
        }
        .download-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .download-card {
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .download-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        .platform-icon {
            width: 50px;
            height: 50px;
            background: #f5f5f5;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 15px;
        }
        .platform-title {
            font-size: 1.3em;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }
        .platform-desc {
            color: #666;
            margin-bottom: 15px;
            line-height: 1.5;
        }
        .download-btn {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s;
        }
        .download-btn:hover {
            background: #45a049;
        }
        .info-section {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 8px;
            margin-top: 30px;
        }
        .info-section h3 {
            color: #333;
            margin-bottom: 15px;
            font-size: 1.4em;
        }
        .feature-list {
            list-style: none;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 10px;
        }
        .feature-list li {
            padding: 8px 0;
            color: #555;
        }
        .feature-list li:before {
            content: "✅ ";
            margin-right: 8px;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            border-top: 1px solid #e0e0e0;
        }
        @media (max-width: 768px) {
            .header h1 { font-size: 2em; }
            .content { padding: 20px; }
            .download-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>LwenaTech Downloads</h1>
            <p>Complete Inventory Management System - Available on All Platforms</p>
        </div>
        
        <div class="content">
            <div class="download-grid">
                <div class="download-card">
                    <div class="platform-icon" style="background: #e3f2fd;">📱</div>
                    <div class="platform-title">Android Mobile</div>
                    <div class="platform-desc">
                        Mobile-optimized inventory management with camera integration.
                        <br><strong>Requirements:</strong> Android 6.0+, 2GB RAM
                    </div>
                    <a href="android/LwenaTech-v$VERSION.apk" class="download-btn">
                        Download APK (25MB)
                    </a>
                </div>
                
                <div class="download-card">
                    <div class="platform-icon" style="background: #f3e5f5;">🌐</div>
                    <div class="platform-title">Web Application</div>
                    <div class="platform-desc">
                        Complete deployment package for static hosting services.
                        <br><strong>Requirements:</strong> Modern browser, HTTPS
                    </div>
                    <a href="web/LwenaTech-Web-v$VERSION.zip" class="download-btn">
                        Download ZIP (15MB)
                    </a>
                </div>
                
                <div class="download-card">
                    <div class="platform-icon" style="background: #e8f5e8;">🖥️</div>
                    <div class="platform-title">Windows Desktop</div>
                    <div class="platform-desc">
                        Native Windows application with installer.
                        <br><strong>Requirements:</strong> Windows 10+, 4GB RAM
                    </div>
                    <a href="#" class="download-btn" style="background: #ccc; cursor: not-allowed;">
                        Coming Soon
                    </a>
                </div>
                
                <div class="download-card">
                    <div class="platform-icon" style="background: #fff3e0;">🍎</div>
                    <div class="platform-title">macOS Desktop</div>
                    <div class="platform-desc">
                        Native macOS application bundle.
                        <br><strong>Requirements:</strong> macOS 10.14+, 4GB RAM
                    </div>
                    <a href="#" class="download-btn" style="background: #ccc; cursor: not-allowed;">
                        Coming Soon
                    </a>
                </div>
                
                <div class="download-card">
                    <div class="platform-icon" style="background: #fff8e1;">🐧</div>
                    <div class="platform-title">Linux Desktop</div>
                    <div class="platform-desc">
                        AppImage for universal Linux compatibility.
                        <br><strong>Requirements:</strong> Ubuntu 18.04+, 4GB RAM
                    </div>
                    <a href="#" class="download-btn" style="background: #ccc; cursor: not-allowed;">
                        Coming Soon
                    </a>
                </div>
                
                <div class="download-card">
                    <div class="platform-icon" style="background: #e8eaf6;">📚</div>
                    <div class="platform-title">Documentation</div>
                    <div class="platform-desc">
                        Complete installation guides and user documentation.
                        <br><strong>Includes:</strong> Setup guides, troubleshooting
                    </div>
                    <a href="docs/INSTALLATION_GUIDE.md" class="download-btn">
                        View Guide
                    </a>
                </div>
            </div>
            
            <div class="info-section">
                <h3>🚀 Key Features</h3>
                <ul class="feature-list">
                    <li>Multi-tenant inventory management</li>
                    <li>Real-time cloud synchronization</li>
                    <li>Product image support with camera</li>
                    <li>PDF reporting and exports</li>
                    <li>Offline capability with sync</li>
                    <li>Role-based user management</li>
                    <li>Category and supplier management</li>
                    <li>Stock alerts and notifications</li>
                    <li>Responsive cross-platform design</li>
                    <li>Secure authentication and encryption</li>
                </ul>
            </div>
        </div>
        
        <div class="footer">
            <p>
                <strong>LwenaTech Inventory Management System v$VERSION</strong><br>
                Built with Flutter & Supabase | 
                <a href="https://github.com/LWENA27/Mem_technology" style="color: #4CAF50;">GitHub</a> | 
                <a href="mailto:support@lwenatech.com" style="color: #4CAF50;">Support</a>
            </p>
        </div>
    </div>
</body>
</html>
EOF

# Create Web ZIP package
echo -e "${YELLOW}📦 Creating web deployment package...${NC}"
cd "$DOWNLOADS_DIR/web"
zip -r "LwenaTech-Web-v$VERSION.zip" .
mv "LwenaTech-Web-v$VERSION.zip" ..
cd ../..

echo
echo -e "${GREEN}✅ DOWNLOADS PREPARED SUCCESSFULLY! ✅${NC}"
echo -e "${GREEN}=================================${NC}"
echo
echo -e "${BLUE}📁 Available Downloads:${NC}"
echo "• Android APK: $DOWNLOADS_DIR/android/LwenaTech-v$VERSION.apk"
echo "• Web Package: $DOWNLOADS_DIR/LwenaTech-Web-v$VERSION.zip"
echo "• Downloads Page: $DOWNLOADS_DIR/index.html"
echo
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Upload the downloads folder to your web server"
echo "2. Access the downloads page at: https://your-domain.com/downloads/"
echo "3. Users can download and install on their preferred platform"
echo "4. Create a GitHub release (tag v$VERSION) to trigger automated builds"
echo
echo -e "${GREEN}🌐 Web Demo Available At: https://your-app-url.netlify.app${NC}"
echo -e "${GREEN}📥 Downloads Available At: https://your-domain.com/downloads/${NC}"