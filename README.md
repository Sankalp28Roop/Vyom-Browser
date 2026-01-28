# Vyom Quantum Browser

A lightweight, privacy-focused web browser built for macOS (Apple Silicon). Designed to be fast, memory-efficient, and beautiful.

## System Requirements
- **OS**: macOS 12.0 (Monterey) or later.
- **Hardware**: Optimized for Mac M1/M2/M3 with 8GB RAM.
- **Disk Space**: ~20MB.

## Key Features
- **Quantum Start Page**: A custom "Vyom Quantum" new tab experience with a minimal tech aesthetic.
- **Privacy First**:
  - Native Content Blocking (Ads/Trackers) via WebKit.
  - Anti-Fingerprinting protection.
  - Auto-HTTPS upgrade.
- **Memory Optimization**:
  - Aggressive background tab suspension (~15MB per suspended tab).
  - Instant wake-up on tab selection.
- **Auto-Maximize**: Launches in full-screen mode for immersion.

## Screenshots

### Start Page
*(The browser uses this background for its immersive start experience)*

> Note: For actual app screenshots, please run the app and capture the window!

## Installation

### Option 1: Build from Source
1.  Clone the repository:
    ```bash
    git clone https://github.com/YOUR_USERNAME/vyom-browser.git
    cd vyom-browser
    ```
2.  Run the build script:
    ```bash
    ./build_app.sh
    ```
3.  Open the app:
    ```bash
    open build/MyBrowser.app
    ```

### Option 2: Download
(Link to your GitHub Releases page would go here)

## License
MIT License.
