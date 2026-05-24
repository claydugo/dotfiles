#!/bin/bash

set -euo pipefail

case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*) OS=windows ;;
    Darwin) OS=macos ;;
    *) OS=linux ;;
esac

: "${XDG_CONFIG_HOME:="$HOME/.config"}"

if [ "$OS" = windows ]; then
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
    export MSYS=winsymlinks:nativestrict
fi

print_message() {
    local color="$1"
    local message="$2"
    printf '\e[%sm%s\e[0m\n' "$color" "$message"
}

is_ci() {
    [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${CI:-}" ]
}

link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ] && [ "$dst" -ef "$src" ]; then
        return 0
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        rm -rf "$dst"
    fi
    if [ "$OS" = windows ]; then
        ln -sfn "$(cygpath -w "$src")" "$dst"
    else
        ln -sfn "$src" "$dst"
    fi
}

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

setup_windows_elevated() {
    is_ci && { print_message "33" "Skipping elevated Windows setup (CI handles it)."; return 0; }
    local devmode longpaths
    devmode=$(powershell -NoProfile -Command "(Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock' -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense" 2>/dev/null | tr -d '\r')
    longpaths=$(powershell -NoProfile -Command "(Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\FileSystem' -Name LongPathsEnabled -ErrorAction SilentlyContinue).LongPathsEnabled" 2>/dev/null | tr -d '\r')
    if [ "$devmode" = "1" ] && [ "$longpaths" = "1" ]; then
        print_message "34" "Windows dev settings already configured (Developer Mode + long paths)."
        return 0
    fi
    local tmp
    tmp="$(mktemp --suffix=.ps1)" || return 0
    cat > "$tmp" <<'PS1'
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name AllowDevelopmentWithoutDevLicense -PropertyType DWord -Value 1 -Force | Out-Null
$paths = @("$env:USERPROFILE\.pixi","$env:USERPROFILE\.local\share\nvim-data","$env:USERPROFILE\.local\state","$env:USERPROFILE\.cache","$env:USERPROFILE\dotfiles","$env:USERPROFILE\AppData\Roaming\fnm")
foreach ($p in $paths) { Add-MpPreference -ExclusionPath $p -ErrorAction SilentlyContinue }
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled -Value 1 -PropertyType DWord -Force | Out-Null
PS1
    print_message "33" "Configuring Windows dev settings (Developer Mode, Defender exclusions, long paths) — accept the UAC prompt..."
    powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$(cygpath -w "$tmp")'" 2>/dev/null ||
        print_message "33" "Elevated Windows setup skipped (elevation declined)."
    rm -f "$tmp"
}

# Windows: install a winget package by id, unless its command is already present.
install_winget() {
    local id="$1" cmd="$2" name="$3"
    if command -v "$cmd" >/dev/null 2>&1; then
        print_message "34" "$name is already installed."
        return 0
    fi
    print_message "32" "Installing $name via winget..."
    winget install --silent --accept-package-agreements --accept-source-agreements --id "$id" >/dev/null 2>&1 ||
        print_message "33" "$name winget install failed (install it manually if needed)."
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

install_node_windows() {
    print_message "32" "Setting up Node via fnm..."
    if command -v fnm >/dev/null 2>&1; then
        fnm install --lts || true
        fnm default lts-latest || true
    else
        print_message "33" "fnm not found; skipping Node setup."
    fi
}

install_pixi() {
    print_message "32" "Installing Pixi package manager..."
    export PATH="$HOME/.pixi/bin:$PATH"
    if ! command -v pixi >/dev/null 2>&1; then
        PIXI_NO_PATH_UPDATE=1 download_and_execute "https://pixi.sh/install.sh"
    else
        print_message "34" "Pixi is already installed."
    fi
}

install_claude_code() {
    print_message "32" "Installing Claude Code..."
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v claude >/dev/null 2>&1; then
        download_and_execute "https://claude.ai/install.sh"
    else
        print_message "34" "Claude Code is already installed."
    fi
}

install_with_pixi_global() {
    local packages=("$@")
    print_message "32" "Installing global CLI tools with Pixi: ${packages[*]}"
    for pkg in "${packages[@]}"; do
        if ! pixi global list 2>/dev/null | grep -Fq "── ${pkg}: "; then
            pixi global install "$pkg"
        else
            print_message "34" "$pkg is already installed globally."
        fi
    done
}

setup_modern_bash() {
    local pixi_bash="$HOME/.pixi/bin/bash"

    if [ ! -x "$pixi_bash" ]; then
        print_message "33" "Pixi bash not found, skipping shell setup"
        return 0
    fi

    if ! grep -qxF "$pixi_bash" /etc/shells 2>/dev/null; then
        print_message "32" "Adding $pixi_bash to /etc/shells..."
        echo "$pixi_bash" | sudo tee -a /etc/shells >/dev/null
    fi

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

setup_powershell() {
    local ps_exe profile profile_unix
    ps_exe=$(command -v pwsh 2>/dev/null || command -v powershell 2>/dev/null || true)
    if [ -z "$ps_exe" ]; then
        print_message "33" "PowerShell not found; skipping profile setup."
        return 0
    fi

    print_message "32" "Setting up PowerShell profile..."
    "$ps_exe" -NoProfile -Command "if (-not (Get-Module -ListAvailable PSFzf)) { try { Install-Module PSFzf -Scope CurrentUser -Force -AcceptLicense } catch {} }" >/dev/null 2>&1 || true

    profile=$("$ps_exe" -NoProfile -Command '$PROFILE.CurrentUserCurrentHost' 2>/dev/null | tr -d '\r')
    [ -z "$profile" ] && return 0
    profile_unix=$(cygpath -u "$profile")
    mkdir -p "$(dirname "$profile_unix")"
    if [ -e "$profile_unix" ] && [ ! -L "$profile_unix" ]; then
        mv "$profile_unix" "$profile_unix.bak.$(date +%s)"
        print_message "33" "Backed up existing PowerShell profile alongside as *.bak.*"
    fi
    link "$HOME/dotfiles/windows/profile.ps1" "$profile_unix"
    print_message "34" "Linked PowerShell profile -> $profile"
}

setup_windows_env() {
    local cfg data cache state
    cfg=$(cygpath -w "$HOME/.config")
    data=$(cygpath -w "$HOME/.local/share")
    cache=$(cygpath -w "$HOME/.cache")
    state=$(cygpath -w "$HOME/.local/state")
    print_message "32" "Persisting XDG environment variables (User scope)..."
    powershell -NoProfile -Command "
        [Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', '$cfg', 'User');
        [Environment]::SetEnvironmentVariable('XDG_DATA_HOME', '$data', 'User');
        [Environment]::SetEnvironmentVariable('XDG_CACHE_HOME', '$cache', 'User');
        [Environment]::SetEnvironmentVariable('XDG_STATE_HOME', '$state', 'User');
        [Environment]::SetEnvironmentVariable('EDITOR', 'nvim', 'User')
    " >/dev/null 2>&1 || print_message "33" "Could not persist user env vars (continuing)."
}

print_message "34" "Setting up dotfiles..."
cd "$HOME/dotfiles/"
if ! is_ci; then
    git submodule update --remote
fi

if [ "$OS" = windows ]; then
    setup_windows_elevated
else
    sudo -v
fi

print_message "32" "Symlinking configuration files..."
link "$HOME/dotfiles/.bashrc" "$HOME/.bashrc"
if [ ! -e "$HOME/.bash_profile" ] || [ -L "$HOME/.bash_profile" ]; then
    # shellcheck disable=SC2016
    printf '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"\n' > "$HOME/.bash_profile"
fi
link "$HOME/dotfiles/.gitignore" "$HOME/.gitignore"
link "$HOME/dotfiles/.gitlab_ci_skip" "$HOME/.gitlab_ci_skip"

mkdir -p "$XDG_CONFIG_HOME/tmux" "${XDG_STATE_HOME:-$HOME/.local/state}/bash"
link "$HOME/dotfiles/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

mkdir -p "$XDG_CONFIG_HOME/git"
link "$HOME/dotfiles/.gitconfig" "$XDG_CONFIG_HOME/git/config"

if [ -f "$HOME/dotfiles/.condarc" ]; then
    mkdir -p "$XDG_CONFIG_HOME/conda"
    link "$HOME/dotfiles/.condarc" "$XDG_CONFIG_HOME/conda/.condarc"
fi

link "$HOME/dotfiles/.claude" "$HOME/.claude"

for item in "$HOME/dotfiles/.config"/*; do
    base_item=$(basename "$item")
    [[ "$base_item" == "karabiner" && "$OS" != "macos" ]] && continue
    [[ "$base_item" == "kitty" && "$OS" == "windows" ]] && continue
    [[ "$base_item" == "psmux" && "$OS" != "windows" ]] && continue
    link "$item" "$XDG_CONFIG_HOME/$base_item"
done

link "$HOME/dotfiles/.ipython" "$HOME/.ipython"

if [ "$OS" = windows ]; then
    install_winget wez.wezterm wezterm "WezTerm"
    install_winget marlocarlo.psmux psmux "psmux (tmux for Windows)"
else
    print_message "32" "Installing Kitty terminal..."
    mkdir -p "$HOME/.local/bin/"
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
fi

print_message "32" "Installing Google Sans Code Nerd Font..."
"$HOME/dotfiles/scripts/install_google_sans_code.sh"

mkdir -p "$HOME/.local/bin"

if [ "$OS" != windows ]; then
    link "$HOME/dotfiles/.local/bin/build_nvim.sh" "$HOME/.local/bin/build_nvim"
fi

if [ -d "$HOME/dotfiles/ramona/scripts" ]; then
    [ -f "$HOME/dotfiles/ramona/scripts/ws" ] && link "$HOME/dotfiles/ramona/scripts/ws" "$HOME/.local/bin/ws"
    [ -f "$HOME/dotfiles/ramona/scripts/drop_caches" ] && link "$HOME/dotfiles/ramona/scripts/drop_caches" "$HOME/.local/bin/drop_caches"
fi

common_cli_tools=(
    nvim
    starship
    eza
    bat
    fzf
    ripgrep
    fd-find
    cmake
    make
    openssl
    rattler-build
    stylua
    selene
    jujutsu
    hyperfine
    tree-sitter-cli
    ty
)

unix_cli_tools=(
    bash
    git
    curl
    tmux
    htop
    wget
    unzip
    fastfetch
)

linux_cli_tools=(xclip fswatch gifski)

windows_cli_tools=(zig fnm ninja)

global_cli_tools=("${common_cli_tools[@]}")
case "$OS" in
    linux) global_cli_tools+=("${unix_cli_tools[@]}" "${linux_cli_tools[@]}") ;;
    macos) global_cli_tools+=("${unix_cli_tools[@]}") ;;
    windows) global_cli_tools+=("${windows_cli_tools[@]}") ;;
esac

install_pixi || { print_message "31" "Failed to install Pixi"; exit 1; }
setup_pixi_environment
install_with_pixi_global "${global_cli_tools[@]}" || { print_message "31" "Failed to install global CLI tools"; exit 1; }

if [ "$OS" = windows ]; then
    install_node_windows || print_message "33" "Node setup via fnm failed (continuing)."
else
    install_nvm || { print_message "31" "Failed to install NVM"; exit 1; }
fi

install_claude_code || { print_message "31" "Failed to install Claude Code"; exit 1; }

if [ "$OS" != windows ]; then
    setup_modern_bash
fi

if [ "$OS" = windows ]; then
    setup_powershell
    setup_windows_env
fi

if ! is_ci; then
    print_message "32" "Configuring git remotes for dotfiles..."
    cd "$HOME/dotfiles"
    git config remote.origin.url git@github.com:claydugo/dotfiles.git
    git config remote.gitlab.url git@gitlab.com:claydugo/dotfiles.git
    git config remote.gitlab.fetch "+refs/heads/*:refs/remotes/gitlab/*"
    git config --replace-all remote.all.pushurl git@github.com:claydugo/dotfiles.git
    git config --add remote.all.pushurl git@gitlab.com:claydugo/dotfiles.git
fi

print_message "32" "Setting up Neovim plugins..."
if [ "$OS" = windows ] && command -v fnm >/dev/null 2>&1; then
    # Put the fnm-managed node on PATH so mason can install npm-based servers.
    eval "$(fnm env)" 2>/dev/null || true
fi
nvim --headless "+Lazy! restore" +qa

print_message "32" "Installing Treesitter parsers and Mason packages..."
nvim --headless -c "lua require('headless_install').run()" -c "qall"

if [ "$OS" = linux ]; then
    if ! grep -q "fs.inotify.max_user_watches=100000" /etc/sysctl.conf; then
        printf 'fs.inotify.max_user_watches=100000\nfs.inotify.max_queued_events=100000\n' | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
    fi

    if command -v gsettings >/dev/null 2>&1 && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }; then
        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']" 2>/dev/null || true
    fi
fi

if git submodule status ramona 2>/dev/null | grep -qv '^-'; then
    if [ -x "$HOME/dotfiles/ramona/work_prefs.sh" ]; then
        print_message "32" "Running work preferences setup..."
        "$HOME/dotfiles/ramona/work_prefs.sh"
    fi
fi

print_message "33" "************************************"
print_message "32" "Setup complete!"
print_message "33" "************************************"
