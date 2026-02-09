# Grabvideo

A bash script that downloads videos from the internet using [yt-dlp](https://github.com/yt-dlp/yt-dlp).

## What it does

1. **Ensures yt-dlp is installed** – Creates `~/.grabvideo` if needed, checks the latest release on GitHub, and downloads the platform-appropriate yt-dlp binary into that directory when it’s missing or outdated.

2. **Installs gum** – Uses [gum](https://github.com/charmbracelet/gum) for the TUI. On macOS it installs via Homebrew if missing; on other platforms it prints instructions to install it.

3. **Prompts for a URL** – If the clipboard contains a URL (starting with `http://` or `https://`), it shows a confirmation dialog. Otherwise it asks you to enter a URL.

4. **Downloads the video** – Runs `~/.grabvideo/yt-dlp` with the URL as argument.

## Supported platforms

- macOS (darwin)
- Linux (x86_64, aarch64)

## Usage

```sh
./grabvideo.sh
```

## macOS app

On macOS, you can build a double-clickable app that opens Terminal and runs grabvideo from the Desktop:

```sh
./build-app.sh
```

This creates `GrabVideo.app`. Move it to your Desktop or Applications. When you double-click it, Terminal opens, changes to the Desktop, runs grabvideo, and closes on success or stays open with an error message on failure.

## Dependencies

- `curl` – for downloading yt-dlp
- `gum` – for the TUI (auto-installed on macOS via Homebrew)
- `ffmpeg` – recommended for yt-dlp (merging, post-processing)
