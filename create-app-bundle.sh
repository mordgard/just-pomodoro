#!/bin/bash

# Create macOS App Bundle for Just Pomodoro

APP_NAME="Just Pomodoro"
BUNDLE_ID="com.yourcompany.justpomodoro"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

echo "Creating app bundle for ${APP_NAME}..."

# Clean up previous bundle
rm -rf "${APP_BUNDLE}"

# Create bundle structure
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${BUILD_DIR}/JustPomodoro" "${APP_BUNDLE}/Contents/MacOS/"

# Copy resources
cp -r "Just Pomodoro/Resources/Assets.xcassets" "${APP_BUNDLE}/Contents/Resources/"

# Copy icon file if it exists
if [ -f "iconfile.icns" ]; then
    cp "iconfile.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    echo "Copied icon file"
fi

# Compile asset catalog to generate Assets.car (required for app icon)
if command -v actool &> /dev/null; then
    echo "Compiling asset catalog..."
    actool --output-format human-readable-text \
           --notices \
           --warnings \
           --platform macosx \
           --minimum-deployment-target 15.0 \
           --target-device mac \
           --compile "${APP_BUNDLE}/Contents/Resources" \
           "${APP_BUNDLE}/Contents/Resources/Assets.xcassets"
    echo "Asset catalog compiled successfully"
fi

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>JustPomodoro</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAccentColorName</key>
    <string>AccentColor</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Copy entitlements
cp "Just Pomodoro/Resources/JustPomodoro.entitlements" "${APP_BUNDLE}/Contents/Resources/"

echo "App bundle created: ${APP_BUNDLE}"
echo ""
echo "To sign the app (optional, for local use):"
echo "  codesign --force --deep --sign - \"${APP_BUNDLE}\""
echo ""
echo "To run the app:"
echo "  open \"${APP_BUNDLE}\""
