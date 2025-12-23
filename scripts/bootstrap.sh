#!/bin/bash

set -euo pipefail

: "${XDG_CONFIG_HOME:="$HOME/.config"}"

print_message() {
    local color="$1"
    local message="$2"
    printf '\e[%sm%s\e[0m\n' "$color" "$message"
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
    if ! command -v pixi >/dev/null 2>&1; then
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
        if ! pixi global list 2>/dev/null | grep -Fq "$pkg"; then
            pixi global install "$pkg"
        else
            print_message "34" "$pkg is already installed globally."
        fi
    done
}

setup_pixi_environment() {
    if [ -f "$HOME/dotfiles/ramona/pixi.toml" ]; then
        print_message "32" "Setting up pixi environment from ramona..."
        ln -sfn "$HOME/dotfiles/ramona/pixi.toml" "$HOME/pixi.toml"
        ln -sfn "$HOME/dotfiles/ramona/pixi.lock" "$HOME/pixi.lock" 2>/dev/null || true
        print_message "34" "Symlinked ~/pixi.toml -> ~/dotfiles/ramona/pixi.toml"
    fi
}

print_message "34" "Setting up dotfiles..."
cd "$HOME/dotfiles/"
git submodule update --remote

sudo -v

print_message "32" "Symlinking configuration files..."
ln -sfn "$HOME/dotfiles/.bashrc" "$HOME/.bashrc"
ln -sfn "$HOME/dotfiles/.gitignore" "$HOME/.gitignore"
ln -sfn "$HOME/dotfiles/.gitlab_ci_skip" "$HOME/.gitlab_ci_skip"

mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -sfn "$HOME/dotfiles/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

mkdir -p "$XDG_CONFIG_HOME/git"

if [ -f "$HOME/dotfiles/.condarc" ]; then
    mkdir -p "$XDG_CONFIG_HOME/conda"
    ln -sfn "$HOME/dotfiles/.condarc" "$XDG_CONFIG_HOME/conda/.condarc"
fi

[ -e "$HOME/.claude" ] && rm -rf "$HOME/.claude"
ln -sfn "$HOME/dotfiles/.claude" "$HOME/.claude"

for item in "$HOME/dotfiles/.config"/*; do
    base_item=$(basename "$item")
    target="$XDG_CONFIG_HOME/$base_item"
    [ -e "$target" ] && rm -rf "$target"
    ln -sfn "$item" "$target"
done

ln -sfn "$HOME/dotfiles/.ipython" "$XDG_CONFIG_HOME/ipython"

print_message "32" "Installing Kitty terminal..."
mkdir -p "$HOME/.local/bin/"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

print_message "32" "Installing Google Sans Code Nerd Font..."
"$HOME/dotfiles/scripts/install_google_sans_code.sh"

ln -sf "$HOME/dotfiles/.local/bin/build_nvim.sh" "$HOME/.local/bin/build_nvim"

if [ -d "$HOME/dotfiles/ramona/scripts" ]; then
    [ -f "$HOME/dotfiles/ramona/scripts/ws" ] && ln -sf "$HOME/dotfiles/ramona/scripts/ws" "$HOME/.local/bin/ws"
    [ -f "$HOME/dotfiles/ramona/scripts/drop_caches" ] && sudo ln -sf "$HOME/dotfiles/ramona/scripts/drop_caches" /usr/sbin/drop_caches
fi

cd "$HOME/dotfiles"
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
    stylua
    gifski
    jujutsu
    hyperfine
)

install_nvm || { print_message "31" "Failed to install NVM"; exit 1; }
install_pixi || { print_message "31" "Failed to install Pixi"; exit 1; }
setup_pixi_environment
install_with_pixi_global "${global_cli_tools[@]}" || { print_message "31" "Failed to install global CLI tools"; exit 1; }

ln -sfn "$HOME/dotfiles/.gitconfig" "$XDG_CONFIG_HOME/git/config"

print_message "32" "Setting up Neovim plugins..."
nvim --headless "+Lazy! restore" +qa
timeout 120 nvim --headless "+sleep 90" +qa || true

if [ "$(uname -s)" = "Linux" ]; then
    if ! grep -q "fs.inotify.max_user_watches=100000" /etc/sysctl.conf; then
        printf 'fs.inotify.max_user_watches=100000\nfs.inotify.max_queued_events=100000\n' | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
    fi

    if command -v gsettings >/dev/null 2>&1 && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }; then
        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']" 2>/dev/null || true
    fi
fi

print_message "33" "************************************"
print_message "32" "Setup complete!"
print_message "33" "************************************"
