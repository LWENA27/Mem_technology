# LwenaTech InventoryMaster SaaS 📦

A comprehensive multi-tenant inventory management system built with Flutter and Supabase, provided by LwenaTech.

Website | GitHub | Support: support@lwenatech.com

## 🌟 Features

### 📱 Multi-Platform Support
- **Web Application**: PWA with offline capabilities
- **Android Mobile**: Native Android 5.0+ support  
- **Windows Desktop**: Native Windows 10/11 application
- **macOS Desktop**: Native macOS 10.14+ application
- **Linux Desktop**: Ubuntu 18.04+ compatible

### 🏢 Business Features
- ✅ **Multi-tenant Architecture**: Support multiple businesses
- ✅ **Product Management**: Complete catalog with multiple images (up to 5 per product)
- ✅ **Inventory Tracking**: Real-time stock levels and alerts
- ✅ **Sales Management**: Track sales with foreign key constraints
- ✅ **User Authentication**: Secure login with role-based access
- ✅ **Real-time Sync**: Cross-platform data synchronization
- ✅ **Image Management**: Supabase Storage integration with cleanup
- ✅ **Export Capabilities**: Generate reports and export data
- ✅ **Offline Support**: View products and data when offline

### 🎨 User Experience
- 🎯 **Intuitive Interface**: Clean Material Design UI
- 📸 **Image Carousel**: Browse multiple product images
- 🔍 **Advanced Search**: Filter by category, brand, and keywords
- 📊 **Dashboard Analytics**: Visual insights and reports
- 🌐 **Responsive Design**: Optimized for all screen sizes
- ⚡ **Fast Performance**: Optimized for speed and efficiency

## 🚀 Quick Start

### Option 1: Download & Install (Recommended)

**🎯 Easy Installation - No Technical Skills Required**

1. **🌐 Try Web Version**: [Live Demo](https://inventorymaster-saas.netlify.app)
2. **� Download Your Platform**: 
   - **Android (25MB)**: [LwenaTech-v1.0.0.apk](https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-v1.0.0.apk)
   - **Windows (50MB)**: [Windows-Installer.zip](https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-Windows-v1.0.0.zip) 
   - **Web Package (15MB)**: [Web-Deploy.zip](https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-Web-v1.0.0.zip)
   - **macOS (60MB)**: [macOS-App.zip](https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-macOS-v1.0.0.zip)
   - **Linux (45MB)**: [Linux-Package.tar.gz](https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-Linux-v1.0.0.tar.gz)

3. **📋 Installation Instructions**:
   - **Android**: Enable "Unknown Sources" → Install APK
   - **Windows**: Extract ZIP → Run `install.bat` as Administrator  
   - **macOS**: Extract ZIP → Drag to Applications folder
   - **Linux**: Extract → Run `chmod +x install.sh && ./install.sh`
   - **Web**: Extract → Upload to web server with HTTPS

**📚 Need Help?**: Check the [Complete Installation Guide](web/downloads/docs/INSTALLATION_GUIDE.md)

**🔗 All Downloads**: [GitHub Releases Page](https://github.com/LWENA27/Mem_technology/releases/latest)

### Option 2: Build from Source

1. **Prerequisites**:
   ```bash
   # Install Flutter
   git clone https://github.com/flutter/flutter.git
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Verify installation
   flutter doctor
   ```

2. **Clone and Setup**:
   ```bash
   git clone https://github.com/LWENA27/Mem_technology.git
   cd Mem_technology
   flutter pub get
   ```

3. **Configure Supabase**:
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Run the SQL scripts in `supabase/migrations/`
   - Update environment variables

4. **Build for Your Platform**:
   ```bash
   # Build all platforms locally
   ./build_releases.sh
   
   # Create downloadable packages
   ./prepare_downloads.sh
   
   # Test downloads locally  
   ./serve_downloads.sh
   
   # Or build individually
   flutter build web                # Web
   flutter build apk                # Android
   flutter build windows           # Windows
   flutter build macos            # macOS  
   flutter build linux            # Linux
   ```

## 🤖 Automated Builds

**GitHub Actions automatically builds all platforms when you create a release tag:**

```bash
# Create and push a new release
git tag v1.0.1
git push origin v1.0.1
```

This triggers multi-platform builds and creates downloadable installers for:
- ✅ Android APK with install instructions
- ✅ Windows ZIP with installer script
- ✅ macOS app bundle  
- ✅ Linux tar.gz with install script
- ✅ Web deployment package

## 📱 Platform Installation

### 🌐 Web Application
- **Access**: Visit the live web app or deploy your own
- **Installation**: Install as PWA for app-like experience
- **Requirements**: Modern browser, internet connection

### 📱 Android Mobile
- **Download**: APK from releases or settings page
- **Installation**: Enable "Unknown Sources", install APK
- **Requirements**: Android 5.0+, 2GB RAM, 100MB storage

### 🖥️ Windows Desktop
- **Download**: ZIP package from releases
- **Installation**: Extract and run `lwenatech.exe`
- **Requirements**: Windows 10/11 (64-bit), 4GB RAM, 1GB storage

### 🍎 macOS Desktop
- **Download**: ZIP package from releases
- **Installation**: Extract and drag to Applications
- **Requirements**: macOS 10.14+, 4GB RAM, 1GB storage

### 🐧 Linux Desktop
- **Download**: tar.gz package from releases
- **Installation**: Extract and run executable
- **Requirements**: Ubuntu 18.04+, 4GB RAM, 1GB storage

## 🔧 Configuration

### Supabase Setup
1. Create project at [supabase.com](https://supabase.com)
2. Import database schema from `supabase/migrations/`
3. Configure Row Level Security (RLS)
4. Set up Storage bucket for images
5. Get your project URL and anonymous key

### Environment Variables (Web)
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anonymous-key
```

## 🏗️ Development

### Project Structure
```
lib/
├── main.dart                     # App entry point
├── models/                      # Data models
│   ├── product.dart            # Product with multi-image support
│   └── ...
├── screens/                    # UI screens
│   ├── customer_view.dart      # Main product catalog
│   ├── inventory_screen.dart   # Admin inventory management
│   ├── settings_screen.dart    # Settings & downloads page
│   └── ...
├── services/                   # Business logic
│   ├── inventory_service.dart  # Product CRUD operations
│   ├── image_upload_service.dart # Multi-image management
│   └── ...
└── widgets/                    # Reusable components
    ├── add_product_dialog.dart # Multi-image product creation
    └── ...
```

### Key Features

#### Multi-Image Support
- **Upload**: Up to 5 images per product with batch processing
- **Display**: Image carousel with navigation indicators
- **Management**: Individual image removal and reordering
- **Storage**: Supabase Storage with automatic cleanup

#### Safe Product Deletion
- **Constraint Checking**: Prevents deletion of products with sales
- **Alternatives**: "Mark as Discontinued" option
- **Cleanup**: Automatic image removal on deletion
- **User Feedback**: Clear error messages and confirmations

## 🚢 Deployment

### Automated Builds
GitHub Actions automatically build all platforms when you create a release tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual Deployment
```bash
# Web deployment
flutter build web
# Deploy build/web to hosting service

# Android APK
./build_android.sh
# Distribute APKs from build/installer/android/

# Windows executable
./build_windows.sh
# Distribute from build/installer/windows/
```

### Hosting Options
- **Web**: Netlify, Vercel, Firebase Hosting
- **Mobile**: Direct download, Google Play Store
- **Desktop**: GitHub Releases, company website

## 📊 Features Showcase

### Admin Interface
- **Product Management**: Add/edit/delete products with multiple images
- **Inventory Control**: Real-time stock tracking
- **Sales Analytics**: Revenue and performance insights
- **User Management**: Multi-tenant user access control

### Customer Interface  
- **Product Catalog**: Browse with advanced filtering
- **Image Gallery**: View multiple product images
- **Search & Filter**: Find products by category, brand, keywords
- **Responsive Design**: Works on all devices

### Technical Excellence
- **Real-time Sync**: Supabase integration for live updates
- **Offline Support**: Cached data for offline viewing
- **Performance**: Optimized images and efficient queries
- **Security**: Row-level security and authentication

## 🛠️ Support & Troubleshooting

### Common Issues
- **Build Failures**: Check `flutter doctor` and platform tools
- **APK Installation**: Enable "Unknown Sources" in Android settings
- **Web Deployment**: Verify environment variables
- **Desktop Apps**: Check system requirements

### Get Help
- 📖 [Documentation](DEPLOYMENT_GUIDE.md)
- 🐛 [GitHub Issues](https://github.com/LWENA27/Mem_technology/issues)
-- 📧 Email: support@lwenatech.com

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

© 2025 Lwena Tech. All rights reserved.

---

**Built with ❤️ using Flutter & Supabase**

*Empowering businesses with modern inventory management across all platforms*