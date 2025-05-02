#!/bin/bash
# Quick install script for new computers
# Focused on setting up vim, tmux, and other essential tools

set -e  # Exit on failure

: ${XDG_CONFIG_HOME:="$HOME/.config"}

print_message() {
    local color="$1"
    local message="$2"
    echo -e "\e[${color}m${message}\e[0m"
}

install_packages() {
    local packages=("$@")
    if [ "$package_manager" == "apt" ]; then
        sudo apt-get install -y "${packages[@]}"
    elif [ "$package_manager" == "dnf" ]; then
        sudo dnf install -y "${packages[@]}"
    elif [ "$package_manager" == "brew" ]; then
        brew install "${packages[@]}"
    fi
}

print_message "34" "Setting up dotfiles..."
cd ~/dotfiles/
git submodule update --remote

# Prompt for sudo upfront
sudo -v

print_message "32" "Symlinking configuration files..."
ln -sfn ~/dotfiles/.bashrc ~/.bashrc
ln -sfn ~/dotfiles/.gitignore ~/.gitignore

mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -sfn ~/dotfiles/.tmux.conf "$XDG_CONFIG_HOME/tmux/tmux.conf"

mkdir -p "$XDG_CONFIG_HOME/git"
ln -sfn ~/dotfiles/.gitconfig "$XDG_CONFIG_HOME/git/config"

mkdir -p "$XDG_CONFIG_HOME/conda"
ln -sfn ~/dotfiles/.condarc "$XDG_CONFIG_HOME/conda/.condarc"

mkdir -p "$XDG_CONFIG_HOME"
for item in ~/dotfiles/.config/*; do
    base_item=$(basename "$item")
    target="$XDG_CONFIG_HOME/$base_item"
    [ -e "$target" ] && rm -rf "$target"
    ln -sfn "$item" "$target"
done

ln -sfn ~/dotfiles/.ipython "$XDG_CONFIG_HOME/ipython"

git config --global user.name "Clay Dugo"
git config --global user.email "claydugo@gmail.com"

ln -sf ~/dotfiles/ramona/scripts/ws ~/.local/bin/ws
ln -sf ~/dotfiles/.local/bin/build_nvim.sh ~/.local/bin/build_nvim
sudo ln -sf ~/dotfiles/ramona/scripts/drop_caches /usr/sbin/drop_caches

os=$(uname -s)

package_manager=""
common_packages=(neovim fswatch tmux ripgrep htop cmake python3 gnome-tweaks fd-find wget openssl bash)

print_message "33" "************************************"
print_message "32" "Setup complete!"
print_message "32" "Run finish_dev_env_setup.sh after opening a new shell."
print_message "33" "************************************"
