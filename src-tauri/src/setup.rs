use anyhow::Result;
use std::fs;
use std::path::Path;
use std::process::Command;
use std::process::Stdio;
use std::{fs::File, io::copy};

// Taken from https://www.thorsten-hans.com/weekly-rust-trivia-download-an-image-to-a-file/
fn download_file(url: &str, file: &mut File) -> Result<()> {
    // Send an HTTP GET request to the URL
    let mut response = reqwest::blocking::get(url)?;
    // Copy the contents of the response to the file
    copy(&mut response, file)?;
    Ok(())
}

fn config_path() -> String {
    let home = std::env::var("HOME").unwrap();
    let config_path = format!("{}/.grabvideo", home);
    config_path
}

fn python3() -> Command {
    let python3 = Command::new("python3");
    python3
}

fn check_python3() {
    let mut python3: Command = python3();
    let test_python = python3.arg("--version");
    test_python
        .stdout(Stdio::null())
        .status()
        .expect("Python3 not found, please install it.");
}

fn install_yt_dlp() -> Result<()> {
    // Install yt-dlp latest release. Note that if the python script is not enough, then we can use the binary
    // "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos";
    let yt_dlp_url = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp";

    let config_path = config_path();
    let yt_dlp_path = format!("{}/yt-dlp", config_path);
    println!("Downloading yt-dlp to {}", yt_dlp_path);
    // Create a new file to write the downloaded file to with executable permissions
    let mut file = fs::OpenOptions::new()
        .write(true)
        .create(true)
        .open(yt_dlp_path)?;
    download_file(&yt_dlp_url, &mut file).expect("Failed to download yt-dlp");
    println!("Done installing yt-dlp");

    Ok(())
}

fn yt_dlp_path() -> String {
    let config_path = config_path();
    let yt_dlp_path = format!("{}/yt-dlp", config_path);
    yt_dlp_path
}

pub fn check_yt_dlp() -> bool {
    let mut python = python3();
    let yt_dlp_check = python.args(&[yt_dlp_path().as_str(), "--version"]);
    let status = yt_dlp_check.status();
    status.unwrap().success()
}

pub fn setup_yt_dlp() -> bool {
    // first check if python3 is installed
    check_python3();
    let config_path = config_path();
    // check if config path is available
    let config_path_exists = Path::new(config_path.as_str()).exists();
    if config_path_exists {
        println!("{} exists", config_path);
    } else {
        // create config path
        fs::create_dir_all(config_path.clone()).expect("Failed to create config path");
    }
    let yt_dlp_path = yt_dlp_path();
    if Path::new(&yt_dlp_path).exists() {
        println!("{} exists", yt_dlp_path);
        return false;
    } else {
        install_yt_dlp().is_ok()
    }
}

pub fn download(url: &str) -> bool {
    if !check_yt_dlp() {
        return false;
    }
    // We are going to download to the desktop
    let home = std::env::var("HOME").unwrap();
    let desktop = format!("{}/Desktop", home);
    // Get python and set the current directory to the desktop
    let mut python = python3();
    python.current_dir(desktop);
    // Prepare command line
    let mut osascript = Command::new("osascript");
    let yt_dlp_path = yt_dlp_path();

    // Escape the URL for AppleScript by replacing quotes and backslashes
    let escaped_url = url.replace("\"", "\\\"").replace("\\", "\\\\");

    let script_download = format!(
        "tell application \"Terminal\" to do script \"cd ~/Desktop; python3 '{}' '{}' && exit\"",
        yt_dlp_path, escaped_url
    );
    let download = osascript.args(["-e", script_download.as_str()]);
    download.status().is_ok()
}
