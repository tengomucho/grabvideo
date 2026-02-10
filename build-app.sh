#!/bin/bash
# Build GrabVideo.app from the project source

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/GrabVideo.app"

mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Launcher script (copied into app bundle; runs with argv[0] inside Contents/MacOS/)
cp "$SCRIPT_DIR/GrabVideo-launcher.sh" "$APP_DIR/Contents/MacOS/GrabVideo"

# Icon: prefer icons/icon.icns, fallback to AppIcon.icns in project root
ICON_FILE=""
if [[ -f "$SCRIPT_DIR/icons/icon.icns" ]]; then
  cp "$SCRIPT_DIR/icons/icon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
  ICON_FILE="	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
"
elif [[ -f "$SCRIPT_DIR/AppIcon.icns" ]]; then
  cp "$SCRIPT_DIR/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
  ICON_FILE="	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
"
fi
cat > "$APP_DIR/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>GrabVideo</string>
	<key>CFBundleIdentifier</key>
	<string>com.grabvideo.app</string>
	<key>CFBundleName</key>
	<string>GrabVideo</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
${ICON_FILE}	<key>LSUIElement</key>
	<true/>
</dict>
</plist>
PLIST

# Copy grabvideo.sh
cp "$SCRIPT_DIR/grabvideo.sh" "$APP_DIR/Contents/Resources/grabvideo.sh"

# Make executables
chmod +x "$APP_DIR/Contents/MacOS/GrabVideo"
chmod +x "$APP_DIR/Contents/Resources/grabvideo.sh"

echo "Built GrabVideo.app"
