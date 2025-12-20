#!/bin/bash

set -e

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

# Get latest release download URL from GitHub API
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/E-Vertin/GoogleSansCode-NerdFont/releases/latest | grep -oP '"browser_download_url":\s*"\K[^"]+')

if [ -z "$DOWNLOAD_URL" ]; then
    print_message "31" "Failed to get download URL from GitHub API"
    exit 1
fi

print_message "34" "Downloading from: $DOWNLOAD_URL"
curl -fsSL -o "$TEMP_DIR/font.tar.xz" "$DOWNLOAD_URL"

print_message "34" "Extracting fonts..."
mkdir -p "$FONT_DIR"
tar -xJf "$TEMP_DIR/font.tar.xz" -C "$TEMP_DIR"

# Find and copy font files
find "$TEMP_DIR" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;

# Update font cache (full rebuild to ensure all caches are updated)
if command -v fc-cache &> /dev/null; then
    print_message "34" "Updating font cache..."
    fc-cache -f
fi

# Verify installation
if fc-match "GoogleSansCode Nerd Font Mono:style=Regular" 2>/dev/null | grep -q "GoogleSansCode"; then
    print_message "32" "✓ Google Sans Code Nerd Font installed to $FONT_DIR"
    print_message "33" "Note: Restart your terminal or press Ctrl+Shift+F5 in kitty to reload fonts"
else
    print_message "31" "Warning: Font installed but fc-match verification failed"
    print_message "31" "Try running: fc-cache -r && fc-match 'GoogleSansCode Nerd Font Mono'"
fi
