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

install_pixi() {
    print_message "32" "Installing Pixi package manager..."
    if ! command -v pixi &> /dev/null; then
        curl -fsSL https://pixi.sh/install.sh | bash
        # Add pixi to PATH for current session
        export PATH="$HOME/.pixi/bin:$PATH"
        # Add to bashrc for future sessions
        echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> ~/.bashrc
    else
        print_message "34" "Pixi is already installed."
    fi
}

install_with_pixi() {
    local packages=("$@")
    print_message "32" "Installing packages with Pixi: ${packages[*]}"
    # Create a pixi.toml file if it doesn't exist
    if [ ! -f ~/dotfiles/pixi.toml ]; then
        cat > ~/dotfiles/pixi.toml << EOF
[project]
name = "dotfiles"
version = "0.1.0"
description = "Personal dotfiles configuration"
channels = ["conda-forge"]
EOF
    fi
    cd ~/dotfiles
    pixi add "${packages[@]}"
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

print_message "32" "Installing Kitty terminal..."
mkdir -p ~/.local/bin/
mkdir -p ~/.local/share/applications/
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

ln -sf ~/dotfiles/ramona/scripts/ws ~/.local/bin/ws
ln -sf ~/dotfiles/.local/bin/build_nvim.sh ~/.local/bin/build_nvim
sudo ln -sf ~/dotfiles/ramona/scripts/drop_caches /usr/sbin/drop_caches

cd ~/dotfiles
git checkout -b "$(hostname)"

# List of all packages to install with pixi
common_packages=(
    neovim 
    fswatch 
    tmux 
    ripgrep 
    htop 
    cmake 
    python 
    gnome-tweaks 
    fd-find 
    wget 
    openssl 
    bash
    curl
    unzip
    starship
)

# Install Pixi package manager
install_pixi

# Install common packages with Pixi
install_with_pixi "${common_packages[@]}"

# OS-specific setup for Linux
if [ "$(uname -s)" == "Linux" ]; then
    # Set up inotify and caps lock as escape
    echo -e "fs.inotify.max_user_watches=100000\nfs.inotify.max_queued_events=100000" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
fi

print_message "33" "************************************"
print_message "32" "Setup complete!"
print_message "33" "************************************"
