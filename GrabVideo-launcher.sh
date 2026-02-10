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
"$GRABVIDEO_SCRIPT"
RESULT=\$?
if [ \$RESULT -eq 0 ]; then
  (sleep 0.3; osascript -e 'tell application "Terminal"' -e 'set n to count of windows' -e 'close front window' -e 'if n is 1 then quit' -e 'end tell' 2>/dev/null) &
  exit 0
else
  echo ""
  echo "An error has occurred. To exit, type Cmd + Q"
  exec \$SHELL
fi
EOF

chmod +x "$LAUNCHER_SCRIPT"
open "$LAUNCHER_SCRIPT"
