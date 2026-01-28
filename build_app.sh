#!/bin/bash

# Configuration
APP_NAME="MyBrowser"
OUTPUT_DIR="build"
EXECUTABLE_NAME="MyBrowser"

echo "🚀 Building $APP_NAME..."

# 0. Generate Icon
chmod +x create_icon.sh
./create_icon.sh

# 1. Clean previous build
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/$APP_NAME.app/Contents/MacOS"
mkdir -p "$OUTPUT_DIR/$APP_NAME.app/Contents/Resources"

# 2. Build via SwiftPM (Release mode for performance)
swift build -c release

# 3. Copy Executable
cp ".build/release/$EXECUTABLE_NAME" "$OUTPUT_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"

# 4. Copy Info.plist
cp "Info.plist" "$OUTPUT_DIR/$APP_NAME.app/Contents/Info.plist"

# 5. Copy Icon
cp "AppIcon.icns" "$OUTPUT_DIR/$APP_NAME.app/Contents/Resources/"

# 6. Copy Start Page Resources
cp Sources/Resources/* "$OUTPUT_DIR/$APP_NAME.app/Contents/Resources/"

echo "✅ Build Complete!"
echo "📂 App is located at: $PWD/$OUTPUT_DIR/$APP_NAME.app"
echo "You can double-click it to run."
