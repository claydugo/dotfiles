#!/bin/bash

set -euo pipefail

FONT_DIR="${HOME}/.local/share/fonts/GoogleSansCodeNerdFont"
TEMP_DIR=$(mktemp -d)

print_message() {
    local color="$1"
    local message="$2"
    echo -e "\e[${color}m${message}\e[0m"
}

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

print_message "32" "Installing Google Sans Code Nerd Font..."

API_RESPONSE=$(curl -fsSL --max-time 30 https://api.github.com/repos/E-Vertin/GoogleSansCode-NerdFont/releases/latest)
DOWNLOAD_URL=$(echo "$API_RESPONSE" | grep -o '"browser_download_url": *"[^"]*"' | head -1 | cut -d'"' -f4)

if [[ -z "${DOWNLOAD_URL:-}" ]]; then
    print_message "31" "Failed to get download URL from GitHub API"
    exit 1
fi

print_message "34" "Downloading from: $DOWNLOAD_URL"
curl -fsSL --max-time 300 -o "$TEMP_DIR/font.tar.xz" "$DOWNLOAD_URL"

print_message "34" "Extracting fonts..."
mkdir -p "$FONT_DIR"
tar -xJf "$TEMP_DIR/font.tar.xz" -C "$TEMP_DIR"

font_count=$(find "$TEMP_DIR" -name "*.ttf" -type f | wc -l)
if [[ "$font_count" -eq 0 ]]; then
    print_message "31" "No .ttf files found in archive"
    exit 1
fi
find "$TEMP_DIR" -name "*.ttf" -type f -exec cp {} "$FONT_DIR/" \;

if command -v fc-cache &>/dev/null; then
    print_message "34" "Updating font cache..."
    fc-cache -f
fi

if command -v fc-match &>/dev/null; then
    if fc-match "GoogleSansCode Nerd Font Mono:style=Regular" 2>/dev/null | grep -q "GoogleSansCode"; then
        print_message "32" "✓ Google Sans Code Nerd Font installed to $FONT_DIR"
        print_message "33" "Note: Restart your terminal or press Ctrl+Shift+F5 in kitty to reload fonts"
    else
        print_message "31" "Warning: Font installed but fc-match verification failed"
        print_message "31" "Try running: fc-cache -r && fc-match 'GoogleSansCode Nerd Font Mono'"
    fi
else
    print_message "33" "Installed $font_count fonts to $FONT_DIR (fc-match not available for verification)"
fi
