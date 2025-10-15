# InventoryMaster SaaS - Deployment & Distribution Guide

This guide explains how to build and distribute InventoryMaster SaaS for multiple platforms.

## 🚀 Quick Start

### Option 1: Build All Platforms
```bash
./build_all.sh
```

### Option 2: Build Individual Platforms
```bash
# Web only
flutter build web

# Android APK
./build_android.sh

# Windows Desktop
./build_windows.sh
```

## 📦 Platform-Specific Instructions

### 🌐 Web Application
**Target**: Web browsers, PWA  
**Build Command**: `flutter build web`  
**Output**: `build/web/`  

**Hosting Options**:
- **Netlify**: Connect GitHub repo, build command: `./build.sh`
- **Vercel**: Deploy with `vercel --prod`
- **Firebase Hosting**: Use `firebase deploy`
- **GitHub Pages**: Deploy `build/web` contents

**Requirements**:
- Modern web browser
- HTTPS for PWA features
- Internet connection for real-time features

### 📱 Android Mobile
**Target**: Android 5.0+ devices  
**Build Command**: `./build_android.sh`  
**Output**: Multiple APK files in `build/installer/android/`

**APK Types**:
- `inventorymaster-universal.apk`: Works on all devices (recommended)
- `inventorymaster-arm64.apk`: 64-bit ARM (modern phones)
- `inventorymaster-arm32.apk`: 32-bit ARM (older phones)
- `inventorymaster-x86_64.apk`: Intel processors (rare)

**Distribution**:
- Direct APK download from website
- Internal app distribution
- Google Play Store (requires signing)

### 🖥️ Windows Desktop
**Target**: Windows 10/11 (64-bit)  
**Build Command**: `./build_windows.sh`  
**Output**: Executable package in `build/installer/windows/`

**Distribution**:
- Direct download from website
- Windows Store (requires certification)
- Enterprise deployment

## 🔧 Configuration

### Environment Variables (Web)
```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anonymous-key"
```

### Android Signing (Production)
1. Generate signing key:
```bash
keytool -genkey -v -keystore release-key.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

2. Create `android/key.properties`:
```
storePassword=yourpassword
keyPassword=yourpassword
keyAlias=release
storeFile=../release-key.keystore
```

3. Update `android/app/build.gradle` for signed builds

## 📋 Release Checklist

### Pre-Build
- [ ] Update version numbers in `pubspec.yaml`
- [ ] Update changelog/release notes
- [ ] Test on target platforms
- [ ] Update Supabase credentials
- [ ] Verify app icons and metadata

### Post-Build
- [ ] Test installation on clean devices/systems
- [ ] Verify app functionality offline/online
- [ ] Check file sizes and performance
- [ ] Update download links in settings screen
- [ ] Create release notes
- [ ] Upload to distribution platforms

## 🌐 Download Page Integration

The app includes a built-in settings screen with download links. Update these URLs in `lib/screens/settings_screen.dart`:

```dart
static const String _windowsDownloadUrl = 'https://yoursite.com/downloads/inventorymaster-windows.exe';
static const String _androidDownloadUrl = 'https://yoursite.com/downloads/inventorymaster-android.apk';
```

## 📈 Distribution Strategies

### 1. Direct Download
- Host files on your website
- Provide installation guides
- Include checksums for security

### 2. GitHub Releases
- Tag releases with version numbers
- Attach build artifacts
- Use GitHub's download stats

### 3. App Stores
- **Google Play**: Standard Android distribution
- **Microsoft Store**: Windows UWP packaging required
- **Web**: PWA through browser stores

### 4. Enterprise Distribution
- Internal app stores
- MDM solutions
- Direct installation packages

## 🛠️ Troubleshooting

### Common Build Issues
- **Flutter not found**: Install Flutter SDK and add to PATH
- **Android build fails**: Check Android SDK installation
- **Windows build fails**: Ensure Windows development tools installed
- **Web build fails**: Check Flutter web support enabled

### Platform-Specific Issues
- **Android**: Enable "Unknown Sources" for APK installation
- **Windows**: SmartScreen warnings for unsigned executables
- **Web**: CORS issues with API calls

## 📊 Monitoring & Analytics

Consider adding:
- App usage analytics
- Crash reporting (Firebase Crashlytics)
- Download tracking
- User feedback collection

## 🔐 Security Considerations

- Sign all production builds
- Use HTTPS for all network communication
- Validate user inputs
- Implement proper authentication
- Regular security updates

---

For technical support: support@lwenatech.com  
GitHub Issues: https://github.com/LWENA27/Mem_technology/issues