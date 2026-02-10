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


# Ensure gum is installed for TUI
ensure_gum() {
  if command -v gum &>/dev/null; then
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      echo "Installing gum..."
      brew install -q gum 2>/dev/null || brew install gum
      ;;
    *)
      echo "gum is required for the TUI. Please install it:" >&2
      echo "  https://github.com/charmbracelet/gum?tab=readme-ov-file#installation" >&2
      exit 1
      ;;
  esac
}
ensure_gum

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

CLIPBOARD=$(get_clipboard | head -1)
if [[ -n "$CLIPBOARD" ]] && [[ "$CLIPBOARD" =~ ^https?:// ]]; then
  gum confirm "Download from: $CLIPBOARD" --affirmative "OK" --negative "Cancel" || exit 1
  URL="$CLIPBOARD"
else
  URL=$(gum input --placeholder "Enter video URL...") || exit 1
fi

if [[ -z "$URL" ]]; then
  exit 0
fi

if [[ "$URL" =~ ^http ]]; then
  PYTHON=$(command -v python3 2>/dev/null || command -v python 2>/dev/null)
  if [[ -z "$PYTHON" ]]; then
    echo "Python is required but not found" >&2
    exit 1
  fi
  "$PYTHON" "$YTDLP_BINARY" "$URL"
else
  echo "$URL"
fi
