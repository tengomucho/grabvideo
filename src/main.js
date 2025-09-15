const { invoke } = window.__TAURI__.core;

let downloadInputEl;
let downloadMsgEl;

async function download() {
  var status = document.getElementById("setup-status");
  status.style.opacity = 1;
  status.textContent = "Downloading...";
  var download_status = await invoke("video_download", { url: downloadInputEl.value });
  if (download_status) {
    status.textContent = "Download launched correctly.";
    setTimeout(() => {
      status.classList.add("fade-out");
    }, 1000);
  } else {
    status.textContent = "⚠️ Failed to download video. ⚠️";
    status.style.color = "red";
  }
}

async function check_setup() {
  var status = document.getElementById("setup-status");
  status.textContent = "Getting ready...";
  var setup_ready = await invoke("check_yt_dlp_setup");

  function tell_setup_ready() {
    status.textContent = "Setup ready.";
    setTimeout(() => {
      status.classList.add("fade-out");
    }, 1000);
  }

  if (setup_ready) {
    tell_setup_ready()
    return;
  }
  status.textContent = "Setting up dependencies (downloading )...";

  var install_ready = await invoke("install_yt_dlp");
  if (install_ready) {
    tell_setup_ready()
    return;
  }
  status.textContent = "⚠️ Failed to setup dependencies, try closing and reopening the app. ⚠️";
  status.style.color = "red";
}

window.addEventListener("DOMContentLoaded", () => {
  downloadInputEl = document.querySelector("#download-input");
  document.querySelector("#download-form").addEventListener("submit", (e) => {
    e.preventDefault();
    download();
  });

  check_setup();
});
