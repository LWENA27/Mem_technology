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
1. **Download APK**: Get `LwenaTech-v1.0.0.apk` from our downloads
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
1. **Download**: Get `LwenaTech-Web-v1.0.0.zip`
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
1. **Download**: Get `LwenaTech-Windows-v1.0.0.zip`
2. **Extract**: Unzip to a temporary folder
3. **Install**: Right-click `install.bat` → "Run as Administrator"
4. **Launch**: Use desktop shortcut or Start Menu

---

## 🍎 macOS Desktop (Coming Soon)

### Requirements
- macOS 10.14 or later
- 4GB RAM minimum
- 1GB storage space

### Installation Steps
1. **Download**: Get `LwenaTech-macOS-v1.0.0.zip`
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
1. **Download**: Get `LwenaTech-Linux-v1.0.0.tar.gz`
2. **Extract**: `tar -xzf LwenaTech-Linux-v1.0.0.tar.gz`
3. **Install**: `cd extracted_folder && chmod +x install.sh && ./install.sh`
4. **Launch**: Run  in terminal or find in applications

### Dependencies
If you encounter issues, install these packages:
```bash
# Ubuntu/Debian
sudo apt install libgtk-3-0 libblkid1 liblzma5

# Fedora
sudo dnf install gtk3 util-linux-libs xz-libs

# Arch
sudo pacman -S gtk3 util-linux xz
```

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

**MEM Technology**  
📧 Email: support@lwenatech.com  
🌐 Website: https://lwenatech.com  
💻 GitHub: https://github.com/LWENA27/Mem_technology  

Built with ❤️ using Flutter & Supabase  
© 2024 MEM Technology. All rights reserved.
