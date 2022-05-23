#!/bin/bash
# First attempt at a quick install script for new computers
# Mainly care about getting vim and tmux up

# run as root
sudo -v

# Symlink first so things like conda install modifying .bashrc happen
ln -sfn ~/dotfiles/.bashrc ~/.bashrc
ln -sfn ~/dotfiles/.tmux.conf ~/.tmux.conf 
# Symlinking entire /nvim/ folder now with lua setup
# which is spread across multiple files for optimized load time
mkdir -p ~/.config/
ln -sf ~/dotfiles/.config/nvim/ ~/.config/

source ~/.bashrc

OS="$(uname -s)"
if test "$OS" = "Darwin"; then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    brew install nvim tmux ripgrep htop
else if test "$OS" = "Linux"; then
    # Use nightly nvim since most good features come after 0.7
    # and nvim on base apt is version 4.3
    add-apt-repository ppa:neovim-ppa/unstable
    # gnome-tweaks for caps lock escape
    add-apt-repository universe
    apt-get update
    apt install neovim tmux ripgrep htop gnome-tweaks sqlite3 libsqlite3-dev
fi

# nvim setup at end since its still not working
nvim --headless -c 'quitall'
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

