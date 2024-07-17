#!/usr/bin/env bash

set -e
set -u

NEOVIM_DIR="$HOME/git/upstream/neovim"
NEOVIM_REPO="git@github.com:neovim/neovim.git"

if [ ! -d "$NEOVIM_DIR" ]; then
    echo "Neovim directory not found. Cloning repository..."
    mkdir -p "$(dirname "$NEOVIM_DIR")"
    git clone "$NEOVIM_REPO" "$NEOVIM_DIR"
fi

cd "$NEOVIM_DIR" || exit 1

git fetch origin

if git diff --quiet origin/master; then
    echo "Already up to date. No changes to pull."
    exit 0
fi

git pull

if sudo -n true 2>/dev/null; then
    sudo rm -rf /usr/local/share/nvim
    sudo make distclean
    sudo make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
else
    echo "This script requires sudo privileges. Please run with sudo or configure sudoers."
    exit 1
fi

echo "Neovim has been successfully updated and installed."
