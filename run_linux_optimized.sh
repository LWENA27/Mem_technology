#!/bin/bash

# Linux Flutter app launcher with GTK optimizations
export GTK_THEME=Adwaita
export GDK_BACKEND=x11
export FLUTTER_ENGINE_SWITCH_1=enable-software-rendering
export FLUTTER_ENGINE_SWITCH_2=disable-gpu-sandbox

echo "Starting InventoryMaster with Linux optimizations..."
echo "GTK Theme: $GTK_THEME"
echo "Backend: $GDK_BACKEND"

# Run the Flutter app
flutter run -d linux --release