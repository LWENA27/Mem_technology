#!/bin/bash

# Linux-specific Flutter build script to reduce screen blinking issues
echo "Building Flutter app for Linux with optimizations..."

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build with specific flags for Linux desktop performance
flutter build linux --release \
  --tree-shake-icons \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --target-platform linux-x64

echo "Linux build completed successfully!"
echo "Executable location: build/linux/x64/release/bundle/lwenatech"
echo ""
echo "To run the app, execute:"
echo "./build/linux/x64/release/bundle/lwenatech"