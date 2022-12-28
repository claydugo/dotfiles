#!/bin/bash
# First attempt at a quick install script for new computers
# Mainly care about getting vim and tmux up

# shift+k to open man pages
echo "Setting up dotfiles..."
# set -e  # exit on failure
# Update submodules since this script depends on them
git submodule update --remote

# run as root
sudo -v

# Exit on fail
set -o errexit

echo "symlinking"
# Symlink first so things like conda install modifying .bashrc happen
ln -sfn ~/dotfiles/.bashrc ~/.bashrc
ln -sfn ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sfn ~/dotfiles/.gitconfig ~/.gitconfig
ln -sfn ~/dotfiles/.gitignore ~/.gitignore
# Symlinking entire /nvim/ folder now with lua setup
# which is spread across multiple files for optimized load time
mkdir -p ~/.config/
ln -sf ~/dotfiles/.config/nvim/ ~/.config/


# Also do kitty now
mkdir -p ~/.config/kitty
ln -sf ~/dotfiles/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf


mkdir -p ~/.local/bin
ln -sf ~/dotfiles/scripts/ws ~/.local/bin/ws

git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Main setup currently using miniforge and the pathing fucks up mambaforge
# on new machine pulls
# this will be fine for now but i'm debating a branch as well
cd ~/dotfiles
git checkout -b $(hostname)

os=$(uname -s)

if [ "$os" = "Linux" ]; then
    echo "linux detected"
    # Use nightly nvim since most good features come after 0.7
    # and nvim on base apt is version 4.3
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo add-apt-repository universe
    sudo apt-get update
    sudo apt install neovim tmux ripgrep htop cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"
    ln -sfn ~/dotfiles/.xprofile ~/.xprofile
    echo "source ~/.xprofile" >> ~/.bashrc
    fonts_dir="$HOME/.fonts"
    mkdir -p $fonts_dir
    cd $fonts_dir
fi
if [ "$os" = "Darwin" ]; then
    echo "mac detected"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install neovim --HEAD
    # mac no longer ships newest bash install with homebrew
    brew install tmux ripgrep htop cmake wget python3 openssl bash
    brew install --cask karabiner-elements
    chsh -s /bin/bash
    echo "eval \"$(/opt/homebrew/bin/brew shellenv)\"" >> ~/.bashrc
    echo "export BASH_SILENCE_DEPRECATION_WARNING=1" >> ~/.bashrc
    fonts_dir="/Library/Fonts/"
    mkdir -p $fonts_dir
    cd $fonts_dir
fi

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip && unzip "FiraCode" -d $fonts_dir && fc-cache -fv

# Sometimes im doing setup before logging in
# So user folders arent created yet
echo "installing conda"
mkdir -p ~/Downloads
cd ~/Downloads
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh

conda update conda --name base

conda config --add channels conda-forge

# Need my LSP
conda install pyright

echo "checking for ramona submodule"
if [ -f ~/dotfiles/ramona/ ]; then
    chmod +x ~/dotfiles/ramona/finish_dev_env_setup.sh
    bash ~/dotfiles/ramona/finish_dev_env_setup.sh
    chmod +x ~/dotfiles/ramona/work_prefs.sh
    bash ~/dotfiles/ramona/work_prefs.sh
fi

echo "************************************"
echo "finished"
echo "dont forget to switch caps lock to esc in gnome gnome-tweaks"
echo "and set the power screen timer to never"
echo "uncomment conda activate"
echo "remove .gitconfig gpg key"
echo "run nvim, close, nvim agan, :PackerInstall"
echo "************************************"


source ~/.bashrc
