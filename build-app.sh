#!/bin/bash
# Build GrabVideo.app from the project source

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/GrabVideo.app"

mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Launcher script
cat > "$APP_DIR/Contents/MacOS/GrabVideo" << 'LAUNCHER'
#!/bin/bash
[[ "$(uname -s)" != "Darwin" ]] && { echo "macOS only"; exit 1; }

BUNDLE_RESOURCES="$(cd "$(dirname "$0")/../Resources" && pwd)"
GRABVIDEO_SCRIPT="$BUNDLE_RESOURCES/grabvideo.sh"
GRABVIDEO_DIR="${HOME}/.grabvideo"
LAUNCHER_SCRIPT="${GRABVIDEO_DIR}/GrabVideoLauncher.command"

mkdir -p "$GRABVIDEO_DIR"
cat > "$LAUNCHER_SCRIPT" << EOF
#!/bin/bash
cd ~/Desktop
sleep 0.5
"$GRABVIDEO_SCRIPT"
RESULT=\$?
if [ \$RESULT -eq 0 ]; then
  (sleep 0.3; osascript -e 'tell application "Terminal" to close front window' 2>/dev/null) &
  exit 0
else
  echo ""
  echo "An error has occurred. To exit, type Cmd + Q"
  exec \$SHELL
fi
EOF

chmod +x "$LAUNCHER_SCRIPT"
open "$LAUNCHER_SCRIPT"
LAUNCHER

# Info.plist
cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
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
	<key>LSUIElement</key>
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
