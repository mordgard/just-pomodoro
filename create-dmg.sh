#!/bin/bash

# Create DMG for Just Pomodoro
# This creates a professional DMG installer

APP_NAME="Just Pomodoro"
APP_BUNDLE="Just Pomodoro.app"
VERSION="1.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
TEMP_DIR="temp_dmg"
MOUNT_DIR="mount_dmg"

# Clean up any previous attempts
rm -f "${DMG_NAME}"
rm -rf "${TEMP_DIR}"
rm -rf "${MOUNT_DIR}"

echo "Creating DMG for ${APP_NAME}..."

# Create temp directory
mkdir -p "${TEMP_DIR}"

# Copy app bundle
cp -r "${APP_BUNDLE}" "${TEMP_DIR}/"

# Copy installation instructions
if [ -f "INSTALL_INSTRUCTIONS.md" ]; then
    cp "INSTALL_INSTRUCTIONS.md" "${TEMP_DIR}/README.txt"
fi

# Create Applications symlink
ln -s /Applications "${TEMP_DIR}/Applications"

# Create the DMG with specific size (will be compressed later)
hdiutil create -srcfolder "${TEMP_DIR}" -volname "${APP_NAME}" -fs HFS+ \
    -format UDRW -size 50m "temp_${DMG_NAME}"

# Mount the DMG
mkdir -p "${MOUNT_DIR}"
hdiutil attach "temp_${DMG_NAME}" -mountpoint "${MOUNT_DIR}"

# Optional: Set custom background and layout using AppleScript
echo 'tell application "Finder"
    tell disk "'${APP_NAME}'"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {400, 100, 900, 400}
        set viewOptions to icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set position of item "'${APP_BUNDLE}'" of container window to {125, 150}
        set position of item "Applications" of container window to {375, 150}
        close
    end tell
end tell' | osascript

# Unmount
hdiutil detach "${MOUNT_DIR}"

# Convert to compressed read-only DMG
hdiutil convert "temp_${DMG_NAME}" -format UDZO -o "${DMG_NAME}"

# Clean up temp files
rm -f "temp_${DMG_NAME}"
rm -rf "${TEMP_DIR}"
rm -rf "${MOUNT_DIR}"

echo ""
echo "✅ DMG created: ${DMG_NAME}"
echo ""
echo "To test the DMG:"
echo "  open \"${DMG_NAME}\""
