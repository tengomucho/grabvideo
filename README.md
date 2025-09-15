# Grabvideo

This is a very simple GUI wrapper for [yt-dlp](https://github.com/yt-dlp/yt-dlp) video for macOS.

I built this for a teacher that is not familiar with the terminal but needs sometimes to grab a video from the internet to show it to her pupils.

The code is based on [Tauri](https://tauri.app/), Rust + HTML.

# Build the App

To build the app while developing, you can run"

```sh
cargo tauri dev
```

To build the bundle you can run:

```sh
cargo tauri build --bundles app
```

For more information, check the Tauri documentation.
