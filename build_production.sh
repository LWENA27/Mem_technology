#!/bin/bash

# 🚀 LwenaTech Production Build Script
# This script builds the Flutter web app for production deployment

echo "🚀 Building LwenaTech for Production..."
echo "======================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

echo "📦 Cleaning previous builds..."
flutter clean

echo "📥 Getting dependencies..."
flutter pub get

echo "🔧 Building for web (production)..."
flutter build web --release --web-renderer html --base-href /

echo "📊 Build Statistics:"
echo "==================="
ls -lh build/web/

echo ""
echo "✅ Production build completed successfully!"
echo ""
echo "📁 Build output: build/web/"
echo "🌐 Ready for deployment to:"
echo "   - Vercel"
echo "   - Netlify" 
echo "   - Firebase Hosting"
echo "   - Any static hosting service"
echo ""
echo "📋 Next Steps:"
echo "1. Deploy the build/web/ folder to your hosting service"
echo "2. Configure your custom domain"
echo "3. Update Supabase auth settings with your domain"
echo "4. Test the production deployment"
echo ""
echo "🎉 Your LwenaTech SaaS is ready for launch!"