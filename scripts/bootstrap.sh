#!/bin/bash

set -e

: "${XDG_CONFIG_HOME:="$HOME/.config"}"

print_message() {
    local color="$1"
    local message="$2"
    echo -e "\e[${color}m${message}\e[0m"
}

install_rustup() {
    print_message "32" "Installing Rust toolchain..."
    if ! command -v rustup &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        print_message "34" "Rustup is already installed."
        rustup update
    fi
}

install_cargo_packages() {
    print_message "32" "Installing Cargo packages..."

    if ! command -v cargo-binstall &> /dev/null; then
        print_message "34" "Installing cargo-binstall..."
        curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
    fi

    cargo binstall --no-confirm --strategies crate-meta-data jj-cli
    cargo binstall --no-confirm hyperfine
    cargo binstall --no-confirm stylua
    cargo binstall --no-confirm gifski || true  # optional, requires compilation
}

install_nvm() {
    print_message "32" "Installing NVM (Node Version Manager)..."
    export NVM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"
    if [ ! -d "$NVM_DIR" ]; then
        mkdir -p "$NVM_DIR"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts
    else
        print_message "34" "NVM is already installed."
    fi
}

install_pixi() {
    print_message "32" "Installing Pixi package manager..."
    if ! command -v pixi &> /dev/null; then
        curl -fsSL https://pixi.sh/install.sh | bash
        export PATH="$HOME/.pixi/bin:$PATH"
    else
        print_message "34" "Pixi is already installed."
    fi
}

install_with_pixi_global() {
    local packages=("$@")
    print_message "32" "Installing global CLI tools with Pixi: ${packages[*]}"
    for pkg in "${packages[@]}"; do
        if ! pixi global list 2>/dev/null | grep -q "^$pkg "; then
            pixi global install "$pkg"
        else
            print_message "34" "$pkg is already installed globally."
        fi
    done
}

setup_pixi_environment() {
    if [ -f ~/dotfiles/ramona/pixi.toml ]; then
        print_message "32" "Setting up pixi environment from ramona..."
        ln -sfn ~/dotfiles/ramona/pixi.toml ~/pixi.toml
        ln -sfn ~/dotfiles/ramona/pixi.lock ~/pixi.lock 2>/dev/null || true
        print_message "34" "Symlinked ~/pixi.toml -> ~/dotfiles/ramona/pixi.toml"
    fi
}

print_message "34" "Setting up dotfiles..."
cd ~/dotfiles/
git submodule update --remote

sudo -v

print_message "32" "Symlinking configuration files..."
ln -sfn ~/dotfiles/.bashrc ~/.bashrc
ln -sfn ~/dotfiles/.gitignore ~/.gitignore
ln -sfn ~/dotfiles/.gitlab_ci_skip ~/.gitlab_ci_skip

mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -sfn ~/dotfiles/.tmux.conf "$XDG_CONFIG_HOME/tmux/tmux.conf"

mkdir -p "$XDG_CONFIG_HOME/git"
# gitconfig symlinked after network installs (has insteadOf HTTPS→SSH)

if [ -f ~/dotfiles/.condarc ]; then
    mkdir -p "$XDG_CONFIG_HOME/conda"
    ln -sfn ~/dotfiles/.condarc "$XDG_CONFIG_HOME/conda/.condarc"
fi

[ -e ~/.claude ] && rm -rf ~/.claude
ln -sfn ~/dotfiles/.claude ~/.claude

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

print_message "32" "Installing Google Sans Code Nerd Font..."
~/dotfiles/scripts/install_google_sans_code.sh

ln -sf ~/dotfiles/.local/bin/build_nvim.sh ~/.local/bin/build_nvim

if [ -d ~/dotfiles/ramona/scripts ]; then
    [ -f ~/dotfiles/ramona/scripts/ws ] && ln -sf ~/dotfiles/ramona/scripts/ws ~/.local/bin/ws
    [ -f ~/dotfiles/ramona/scripts/drop_caches ] && sudo ln -sf ~/dotfiles/ramona/scripts/drop_caches /usr/sbin/drop_caches
fi

cd ~/dotfiles
git checkout "$(hostname)" 2>/dev/null || git checkout -b "$(hostname)" 2>/dev/null || true

global_cli_tools=(
    git
    nvim
    tmux
    starship
    eza
    bat
    fzf
    ripgrep
    fd-find
    cmake
    make
    python
    htop
    wget
    curl
    unzip
    openssl
    xclip
    fswatch
    rattler-build
    fastfetch
)

linux_desktop_packages=(
    gnome-tweaks
)

install_rustup
install_cargo_packages
install_nvm
install_pixi
setup_pixi_environment
install_with_pixi_global "${global_cli_tools[@]}"

# Symlink gitconfig after network installs (has insteadOf HTTPS→SSH)
ln -sfn ~/dotfiles/.gitconfig "$XDG_CONFIG_HOME/git/config"

if [ "$(uname -s)" == "Linux" ]; then
    print_message "32" "Installing Linux desktop packages..."
    sudo apt-get update
    sudo apt-get install -y "${linux_desktop_packages[@]}"

    if ! grep -q "fs.inotify.max_user_watches=100000" /etc/sysctl.conf; then
        echo -e "fs.inotify.max_user_watches=100000\nfs.inotify.max_queued_events=100000" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
    fi

    if command -v gsettings &>/dev/null && [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']" 2>/dev/null || true
    fi
fi

print_message "33" "************************************"
print_message "32" "Setup complete!"
print_message "33" "************************************"
