#!/bin/bash

# Build script for Just Pomodoro

echo "Building Just Pomodoro..."

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "Error: Package.swift not found. Please run this script from the 'Just Pomodoro' directory."
    exit 1
fi

# Build using Swift Package Manager
echo "Building with Swift Package Manager..."
swift build -c release

if [ $? -eq 0 ]; then
    echo ""
    echo "Build successful!"
    echo "Executable location: .build/release/JustPomodoro"
    echo ""
    echo "To run the app:"
    echo "  .build/release/JustPomodoro"
    echo ""
    echo "To create an app bundle:"
    echo "  ./create-app-bundle.sh"
else
    echo "Build failed."
    exit 1
fi
