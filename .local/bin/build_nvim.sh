#!/usr/bin/env bash
set -e
set -u

NEOVIM_DIR="$HOME/git/upstream/neovim"
NEOVIM_REPO="https://github.com/neovim/neovim.git"

if [ ! -d "$NEOVIM_DIR" ]; then
    echo "Neovim directory not found. Cloning repository..."
    mkdir -p "$(dirname "$NEOVIM_DIR")"
    git clone "$NEOVIM_REPO" "$NEOVIM_DIR"
fi

cd "$NEOVIM_DIR" || exit 1
git fetch origin

if git diff --quiet origin/master; then
    echo "Already up to date. No changes to pull."
fi

git pull

# Check for sudo access and prompt if necessary
if ! sudo -v; then
    echo "This script requires sudo privileges. Please enter your password when prompted."
    sudo -k  # Reset sudo timestamp
fi

# Now use sudo for the commands that need it
sudo rm -rf /usr/local/share/nvim
sudo make distclean
sudo make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

echo "Neovim has been successfully updated and installed."
