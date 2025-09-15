mod setup;
use setup::*;

#[tauri::command]
fn check_yt_dlp_setup() -> bool {
    check_yt_dlp()
}

#[tauri::command]
fn install_yt_dlp() -> bool {
    setup_yt_dlp()
}

#[tauri::command]
fn video_download(url: &str) -> bool {
    download(url)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![
            check_yt_dlp_setup,
            install_yt_dlp,
            video_download
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
