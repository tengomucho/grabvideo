#!/usr/bin/env bash
set -e

GRABVIDEO_DIR="${HOME}/.grabvideo"
VERSION_FILE="${GRABVIDEO_DIR}/version"
YTDLP_BINARY="${GRABVIDEO_DIR}/yt-dlp"
GITHUB_API="https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"

# Ensure ~/.grabvideo exists
mkdir -p "$GRABVIDEO_DIR"

# Fetch latest release tag from GitHub
get_latest_tag() {
  local tag

  # Try GitHub API first
  local resp
  resp=$(curl -sL "$GITHUB_API" 2>/dev/null) || true
  if [[ -n "$resp" ]]; then
    if command -v jq &>/dev/null; then
      tag=$(echo "$resp" | jq -r '.tag_name // empty' 2>/dev/null)
    fi
    if [[ -z "$tag" ]] || [[ "$tag" == "null" ]]; then
      tag=$(echo "$resp" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi
  fi

  # Fallback: parse tag from releases/latest redirect (avoids API rate limits)
  if [[ -z "$tag" ]] || [[ "$tag" == "null" ]]; then
    local location
    location=$(curl -sI -L "https://github.com/yt-dlp/yt-dlp/releases/latest" 2>/dev/null | grep -i "^[Ll]ocation:" | tail -1)
    if [[ "$location" =~ tag/([^[:space:]]+)[[:space:]]*$ ]]; then
      tag="${BASH_REMATCH[1]}"
    fi
  fi

  if [[ -z "$tag" ]] || [[ "$tag" == "null" ]]; then
    echo "Failed to determine latest yt-dlp release from GitHub" >&2
    exit 1
  fi

  echo "$tag"
}

# Get default browser name for yt-dlp --cookies-from-browser (brave, chrome, chromium, edge, firefox, opera, safari, vivaldi, whale)
get_default_browser() {
  local bundle_id desktop_name
  case "$(uname -s)" in
    Darwin)
      bundle_id=$("${PYTHON:-python3}" -c "
import plistlib, os
path = os.path.expanduser('~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist')
try:
    with open(path, 'rb') as f:
        data = plistlib.load(f)
    for h in data.get('LSHandlers', []):
        if h.get('LSHandlerURLScheme') in ('https', 'http'):
            print(h.get('LSHandlerRoleAll', ''))
            break
except Exception:
    pass
" 2>/dev/null)
      case "$bundle_id" in
        com.apple.Safari) echo "safari" ;;
        com.google.Chrome|com.google.chrome) echo "chrome" ;;
        com.microsoft.edgemac) echo "edge" ;;
        org.mozilla.firefox) echo "firefox" ;;
        com.operasoftware.Opera) echo "opera" ;;
        com.brave.Browser) echo "brave" ;;
        org.chromium.Chromium) echo "chromium" ;;
        com.vivaldi.Vivaldi) echo "vivaldi" ;;
        com.whale.Whale|com.naver.whale) echo "whale" ;;
        *) true ;;
      esac
      ;;
    Linux)
      desktop_name=$(xdg-mime query default x-scheme-handler/https 2>/dev/null || xdg-mime query default x-scheme-handler/http 2>/dev/null)
      case "$desktop_name" in
       *firefox*) echo "firefox" ;;
       *chrome*|*chromium*) echo "chrome" ;;
       *brave*) echo "brave" ;;
       *edge*) echo "edge" ;;
       *opera*) echo "opera" ;;
       *vivaldi*) echo "vivaldi" ;;
        *) true ;;
      esac
      ;;
    *) true ;;
  esac
}

# Compare versions (simple string comparison; yt-dlp uses YYYY.MM.DD format)
version_needs_update() {
  local installed="$1"
  local latest="$2"

  if [[ -z "$installed" ]] || [[ ! -f "$YTDLP_BINARY" ]]; then
    return 0  # Needs update
  fi

  if [[ "$installed" == "$latest" ]]; then
    return 1  # Up to date
  fi

  return 0  # Needs update
}


# Ensure dialog is installed for TUI (avoids gum + macOS Terminal double-prompt issue)
ensure_dialog() {
  if command -v dialog &>/dev/null; then
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      echo "Installing dialog..."
      brew install -q dialog 2>/dev/null || brew install dialog
      ;;
    *)
      echo "dialog is required for the TUI. Please install it (e.g. apt install dialog, dnf install dialog):" >&2
      exit 1
      ;;
  esac
}
ensure_dialog

# Ensure deno is installed to allow yt-dlp to download videos that require authentication
ensure_deno() {
  if command -v deno &>/dev/null; then
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      echo "Installing deno..."
      brew install -q deno 2>/dev/null || brew install deno
      ;;
    *)
      echo "deno is required to download videos that require authentication. Please install it:" >&2
      echo "  https://deno.com/download" >&2
      exit 1
      ;;
  esac
}
ensure_deno

# Get clipboard content if possible
get_clipboard() {
  case "$(uname -s)" in
    Darwin)
      pbpaste 2>/dev/null || true
      ;;
    Linux)
      if command -v wl-paste &>/dev/null; then
        wl-paste 2>/dev/null || true
      elif command -v xclip &>/dev/null; then
        xclip -selection clipboard -o 2>/dev/null || true
      elif command -v xsel &>/dev/null; then
        xsel --clipboard --output 2>/dev/null || true
      fi
      ;;
    *)
      true
      ;;
  esac
}

# Main
LATEST_TAG=$(get_latest_tag)

if [[ -z "$LATEST_TAG" ]]; then
  echo "Failed to determine latest yt-dlp release" >&2
  exit 1
fi

INSTALLED_VERSION=""
[[ -f "$VERSION_FILE" ]] && INSTALLED_VERSION=$(cat "$VERSION_FILE")

if version_needs_update "$INSTALLED_VERSION" "$LATEST_TAG"; then
  DOWNLOAD_URL="https://github.com/yt-dlp/yt-dlp/releases/download/${LATEST_TAG}/yt-dlp"
  TEMP_FILE="${GRABVIDEO_DIR}/yt-dlp.$$"

  if ! curl -sL -o "$TEMP_FILE" "$DOWNLOAD_URL"; then
    echo "Failed to download yt-dlp" >&2
    rm -f "$TEMP_FILE"
    exit 1
  fi

  chmod +x "$TEMP_FILE"
  mv "$TEMP_FILE" "$YTDLP_BINARY"
  echo "$LATEST_TAG" > "$VERSION_FILE"
  echo "Downloaded yt-dlp $LATEST_TAG to $YTDLP_BINARY"
fi

DEFAULT_URL=""
CLIPBOARD=$(get_clipboard | head -1)
if [[ -n "$CLIPBOARD" ]] && [[ "$CLIPBOARD" =~ ^https?:// ]]; then
  DEFAULT_URL="$CLIPBOARD"
fi
URL=$(dialog --stdout --inputbox "Enter video URL:" 8 60 2>/dev/tty "$DEFAULT_URL") || exit 0

if [[ -z "$URL" ]]; then
  exit 0
fi

PYTHON=$(command -v python3 2>/dev/null || command -v python 2>/dev/null)
if [[ -z "$PYTHON" ]]; then
  echo "Python is required but not found" >&2
  exit 1
fi
BROWSER=$(get_default_browser)
if [[ -n "$BROWSER" ]]; then
  "$PYTHON" "$YTDLP_BINARY" --cookies-from-browser "$BROWSER" "$URL"
else
  "$PYTHON" "$YTDLP_BINARY" "$URL"
fi
