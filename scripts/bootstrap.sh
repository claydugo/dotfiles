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

print_message "32" "Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh

cd ~/dotfiles
git checkout -b "$(hostname)"

os=$(uname -s)

package_manager=""
common_packages=(neovim fswatch tmux ripgrep htop cmake python3 gnome-tweaks fd-find wget openssl bash)

if [ "$os" == "Linux" ]; then
    if command -v dnf &> /dev/null; then
        print_message "31" "Fedora detected."
        package_manager="dnf"
        print_message "32" "Installing Fedora packages..."
        sudo dnf upgrade -y
        sudo dnf install -y epel-release
    elif command -v apt-get &> /dev/null; then
        print_message "31" "Debian detected."
        package_manager="apt"
        print_message "32" "Installing Debian packages..."
        sudo apt-get update
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
elif [ "$os" == "Darwin" ]; then
    print_message "31" "macOS detected."
    package_manager="brew"
    print_message "32" "Installing Homebrew and packages..."
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        print_message "34" "Homebrew is already installed."
    fi
    brew update
else
    echo "Unsupported operating system: $os"
    exit 1
fi

if [ "$package_manager" == "apt" ] || [ "$package_manager" == "dnf" ]; then
    install_packages "${common_packages[@]}"
elif [ "$package_manager" == "brew" ]; then
    install_packages "${common_packages[@]}"
    brew install --cask karabiner-elements
    chsh -s /bin/bash
    echo "export BASH_SILENCE_DEPRECATION_WARNING=1" >> ~/.bashrc
fi

if [ "$os" == "Linux" ]; then
    echo -e "fs.inotify.max_user_watches=100000\nfs.inotify.max_queued_events=100000" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
    fonts_dir="$HOME/.fonts"
    mkdir -p "$fonts_dir"
    cd "$fonts_dir"
elif [ "$os" == "Darwin" ]; then
    fonts_dir="/Library/Fonts/"
    mkdir -p "$fonts_dir"
    cd "$fonts_dir"
fi

print_message "32" "Installing Nerd Fonts..."
if command -v wget &> /dev/null; then
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
elif command -v curl &> /dev/null; then
    curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
else
    echo "Neither wget nor curl is installed. Please install one to proceed."
    exit 1
fi
unzip "FiraCode.zip" -d "$fonts_dir"
fc-cache -fv

print_message "32" "Installing Conda (Mambaforge)..."
mkdir -p ~/Downloads
cd ~/Downloads
conda_script="Mambaforge-$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m).sh"
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/${conda_script}"
bash "${conda_script}" -b -p "$HOME/mambaforge"
echo "export PATH=\"$HOME/mambaforge/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc

print_message "33" "************************************"
print_message "32" "Setup complete!"
print_message "32" "Run finish_dev_env_setup.sh after opening a new shell."
print_message "33" "************************************"
