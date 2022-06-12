#!/bin/bash
# First attempt at a quick install script for new computers
# Mainly care about getting vim and tmux up

# Update submodules since this script depends on them
git submodule update --remote

# run as root
sudo -v

# Symlink first so things like conda install modifying .bashrc happen
ln -sfn ~/dotfiles/.bashrc ~/.bashrc
ln -sfn ~/dotfiles/.tmux.conf ~/.tmux.conf 
# Symlinking entire /nvim/ folder now with lua setup
# which is spread across multiple files for optimized load time
mkdir -p ~/.config/
ln -sf ~/dotfiles/.config/nvim/ ~/.config/
# Also do alacritty now
mkdir -p ~/.config/alacritty
ln -sf ~/dotfiles/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

. .bashrc

# Use nightly nvim since most good features come after 0.7
# and nvim on base apt is version 4.3
add-apt-repository ppa:neovim-ppa/unstable
# gnome-tweaks for caps lock escape
add-apt-repository universe
apt-get update
apt install neovim tmux ripgrep htop gnome-tweaks cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

# Install rustup - for alacritty
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup override set stable
rustup update stable
# Install alacritty
cargo install alacritty
cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
desktop-file-install extra/linux/Alacritty.desktop
update-desktop-database

# Install Nerd Font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "FireCode Nerd Font.ttf" https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
if [ -f ~/dotfiles/ramona/setup_dev_env.sh ]; then
    chmod +x ~/dotfiles/ramona/setup_dev_env.sh
    bash ~/dotfiles/ramona/setup_dev_env.sh
fi


# nvim setup at end since its still not working
nvim --headless -c 'quitall'
nvim --headless -c 'autocmd User PackerInstall quitall' -c 'PackerComplete'
