#!/bin/bash

set -euo pipefail

: "${XDG_CONFIG_HOME:="$HOME/.config"}"

print_message() {
    local color="$1"
    local message="$2"
    printf '\e[%sm%s\e[0m\n' "$color" "$message"
}

# Download and execute with retry logic
download_and_execute() {
    local url="$1"
    local max_retries=3
    local retry_count=0
    local retry_delay=5

    while [ $retry_count -lt $max_retries ]; do
        if curl -fsSL --max-time 120 "$url" | bash; then
            return 0
        fi

        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            print_message "33" "Download failed, retrying in ${retry_delay}s (attempt $retry_count/$max_retries)..."
            sleep "$retry_delay"
        fi
    done

    print_message "31" "Failed to download and execute from $url after $max_retries attempts"
    return 1
}

install_nvm() {
    print_message "32" "Installing NVM (Node Version Manager)..."
    export NVM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"
    if [ ! -d "$NVM_DIR" ]; then
        mkdir -p "$NVM_DIR"
        download_and_execute "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts
    else
        print_message "34" "NVM is already installed."
    fi
}

install_pixi() {
    print_message "32" "Installing Pixi package manager..."
    if ! command -v pixi >/dev/null 2>&1; then
        download_and_execute "https://pixi.sh/install.sh"
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

setup_modern_bash() {
    local pixi_bash="$HOME/.pixi/bin/bash"

    # Verify pixi bash exists and is executable
    if [ ! -x "$pixi_bash" ]; then
        print_message "33" "Pixi bash not found, skipping shell setup"
        return 0
    fi

    # Add to /etc/shells if not present
    if ! grep -qxF "$pixi_bash" /etc/shells 2>/dev/null; then
        print_message "32" "Adding $pixi_bash to /etc/shells..."
        echo "$pixi_bash" | sudo tee -a /etc/shells >/dev/null
    fi

    # Switch shell if not already using pixi bash
    if [ "$SHELL" != "$pixi_bash" ]; then
        print_message "32" "Switching default shell to modern bash..."
        sudo chsh -s "$pixi_bash" "$USER"
        print_message "32" "Shell changed to $pixi_bash (logout/login to take effect)"
    else
        print_message "34" "Already using pixi bash as default shell."
    fi
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
# Kitty installer uses 'sh /dev/stdin' with args, so use inline retry
kitty_installed=false
for attempt in 1 2 3; do
    if curl -fsSL --max-time 120 https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n; then
        kitty_installed=true
        break
    fi
    print_message "33" "Kitty install failed, attempt $attempt/3..."
    sleep 5
done
$kitty_installed || { print_message "31" "Failed to install Kitty"; exit 1; }

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
    bash
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
setup_modern_bash

ln -sfn "$HOME/dotfiles/.gitconfig" "$XDG_CONFIG_HOME/git/config"

print_message "32" "Setting up Neovim plugins..."
nvim --headless "+Lazy! restore" +qa

print_message "32" "Installing Treesitter parsers and Mason packages..."
nvim --headless -c "lua require('headless_install').run()" -c "qall"

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
