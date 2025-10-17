#!/bin/bash

# LwenaTech Inventory Management - Production Setup Script
# This script guides you through setting up the production environment

set -e  # Exit on any error

echo "🚀 LwenaTech Production Setup Script"
echo "===================================="
echo ""

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check prerequisites
echo "1. Checking prerequisites..."
echo "----------------------------"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi
print_status "Flutter is installed"

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    print_warning "Supabase CLI is not installed. You can install it with:"
    echo "  npm install -g supabase"
    echo "  or follow: https://supabase.com/docs/guides/cli"
    echo ""
    read -p "Do you want to continue without Supabase CLI? (y/N): " continue_without_cli
    if [[ ! $continue_without_cli =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_status "Supabase CLI is installed"
fi

echo ""
echo "2. Production Supabase Project Setup"
echo "-----------------------------------"
print_info "You need to create a new Supabase project for production."
print_info "Visit: https://supabase.com/dashboard"
echo ""
print_warning "Manual steps required:"
echo "1. Create a new Supabase project"
echo "2. Go to Settings > API to get your project URL and anon key"
echo "3. Copy the database migrations from supabase/migrations/"
echo "4. Set up authentication providers if needed"
echo ""

read -p "Have you created your production Supabase project? (y/N): " supabase_ready
if [[ ! $supabase_ready =~ ^[Yy]$ ]]; then
    print_info "Please create your Supabase project first, then run this script again."
    exit 0
fi

echo ""
read -p "Enter your production Supabase URL (https://xxx.supabase.co): " supabase_url
read -p "Enter your production Supabase anon key: " supabase_anon_key

if [[ -z "$supabase_url" || -z "$supabase_anon_key" ]]; then
    print_error "Both Supabase URL and anon key are required!"
    exit 1
fi

echo ""
echo "3. Updating Production Configuration"
echo "-----------------------------------"

# Update the app_config.dart file
CONFIG_FILE="lib/config/app_config.dart"
if [[ ! -f "$CONFIG_FILE" ]]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Backup the original file
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
print_status "Created backup of configuration file"

# Update the production URLs in the config file
sed -i "s|static const String _prodSupabaseUrl = '.*';|static const String _prodSupabaseUrl = '$supabase_url';|g" "$CONFIG_FILE"
sed -i "s|static const String _prodSupabaseAnonKey = '.*';|static const String _prodSupabaseAnonKey = '$supabase_anon_key';|g" "$CONFIG_FILE"
print_status "Updated production configuration"

echo ""
echo "4. Building Flutter Web for Production"
echo "-------------------------------------"

# Clean previous build
print_info "Cleaning previous build..."
flutter clean
flutter pub get

# Build for web production
print_info "Building Flutter web app..."
flutter build web --release

if [[ $? -eq 0 ]]; then
    print_status "Flutter web build completed successfully!"
    print_info "Build output is in: build/web/"
else
    print_error "Flutter build failed!"
    exit 1
fi

echo ""
echo "5. Production Deployment Options"
echo "-------------------------------"
print_info "Your app is now built and ready for deployment!"
print_info "Build location: build/web/"
echo ""
print_info "Deployment options:"
echo "  1. Vercel: https://vercel.com/"
echo "     - Connect your GitHub repo"
echo "     - Set build command: flutter build web --release"
echo "     - Set output directory: build/web"
echo ""
echo "  2. Netlify: https://netlify.com/"
echo "     - Drag and drop build/web folder"
echo "     - Or connect GitHub repo with same settings as Vercel"
echo ""
echo "  3. Firebase Hosting:"
echo "     - firebase login"
echo "     - firebase init hosting"
echo "     - firebase deploy"
echo ""

echo ""
echo "6. Post-Deployment Tasks"
echo "-----------------------"
print_warning "Don't forget to:"
echo "1. Create Super Admin account in production:"
echo "   Email: adamlwena22@gmail.com"
echo "   Password: SuperAdmin123"
echo ""
echo "2. Test the following in production:"
echo "   - User registration and login"
echo "   - Product management (CRUD operations)"
echo "   - Sales recording and reports"
echo "   - Super Admin dashboard access"
echo ""
echo "3. Configure custom domain and SSL certificates"
echo ""

print_status "Production setup completed!"
print_info "Your LwenaTech Inventory Management system is ready for deployment! 🎉"

echo ""
print_info "Support: https://chat.whatsapp.com/B8RUxQsQM665hjVm3Z05lc?mode=ems_share_t"
echo "Contact: adamlwena22@gmail.com"