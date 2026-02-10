# Grabvideo

A bash script that downloads videos from the internet using [yt-dlp](https://github.com/yt-dlp/yt-dlp).

## What it does

1. **Ensures yt-dlp is installed** – Creates `~/.grabvideo` if needed, checks the latest release on GitHub, and downloads the Python (platform-independent) yt-dlp into that directory when it’s missing or outdated. Runs it with python3 or python.

2. **Installs dialog** – Uses [dialog](https://invisible-island.net/dialog/) for the TUI. On macOS it installs via Homebrew if missing; on other platforms it prints instructions to install it.

3. **Prompts for a URL** – If the clipboard contains a URL (starting with `http://` or `https://`), it shows a confirmation dialog. Otherwise it asks you to enter a URL.

4. **Downloads the video** – Runs `python ~/.grabvideo/yt-dlp` with the URL as argument.

## Supported platforms

- macOS, Linux (any architecture with Python 3)

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
- `python3` or `python` – for running yt-dlp
- `dialog` – for the TUI (auto-installed on macOS via Homebrew)
- `ffmpeg` – recommended for yt-dlp (merging, post-processing)
