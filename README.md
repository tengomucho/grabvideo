# Grabvideo

A super-simpler video downloader based on [yt-dlp](https://github.com/yt-dlp/yt-dlp).

The reason I built this instead of just using yt-dlp is that there are people that might not be familiar with the terminal, but that could still want to download a video to use for work, e.g.: some teachers that might not comfortable using the terminal but that want to work with a video on class when internet connection is unreliable.

## Install macOS application bundle

You can install GrabVideo as a ready-to-use macOS application bundle (no Terminal knowledge required):

Go to [the latest release page](https://github.com/tengomucho/grabvideo/releases/latest) and download the `GrabVideo.zip` file. Unzip it, then move `GrabVideo.app` to your Desktop or Applications folder.

**First launch:** macOS may say the app "could not be verified" (the app is open-source and not signed with an Apple certificate). Use **Right-click → Open** and then click "Open" in the dialog.
Or **System Settings → Privacy & Security** and use “Open Anyway” when the app is blocked.

After that you can open it normally by double-clicking.

The app will open your Terminal, run the video downloader, and close the window for you when it finishes (or leave it open with an error if something went wrong).


## What the internal shell script does does

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
