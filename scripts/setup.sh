#!/bin/bash
# First attempt at a quick install script for new computers
# Mainly care about getting vim and tmux up

# shift+k to open man pages
echo -e "\e[34Setting up dotfiles...\e[0m"
# set -e  # exit on failure
# Update submodules since this script depends on them
cd ~/dotfiles/
git submodule update --remote

# run as root
sudo -v

# Exit on fail
set -o errexit

echo -e "\e[32mSymlinking...\e[0m"
# Symlink first so things like conda install modifying .bashrc happen
ln -sfn ~/dotfiles/.bashrc ~/.bashrc
ln -sfn ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sfn ~/dotfiles/.gitignore ~/.gitignore

git config --global user.name "Clay Dugo"
git config --global user.email "claydugo@gmail.com"
mkdir -p ~/.config/

# dont care about being nice here
for item in ~/dotfiles/.config/*; do
  base_item=$(basename "$item")
  target="$HOME/.config/$base_item"
  if [ -d "$target" ]; then
    rm -rf "$target"
  fi
  ln -sfn "$item" "$target"
done

mkdir -p ~/.ipython/profile_default/startup/
ln -sf ~/dotfiles/.ipython/profile_default/startup/00-conf.py ~/.ipython/profile_default/startup/00-conf.py


echo -e "\e[32minstalling kitty...\e[0m"
mkdir -p ~/.local/bin/
mkdir -p ~/.local/share/applications/
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

ln -sf ~/dotfiles/ramona/scripts/ws ~/.local/bin/ws
ln -sf ~/dotfiles/.local/bin/build_nvim.sh ~/.local/bin/build_nvim
sudo ln -sf ~/dotfiles/ramona/scripts/drop_caches /usr/sbin/drop_caches

# Replaces git bash prompt for me
echo -e "\e[32minstalling starship...\e[0m"
curl -sS https://starship.rs/install.sh | sh

cd ~/dotfiles
git checkout -b "$(hostname)"


os=$(uname -s)

if [ "$os" = "Linux" ]; then
    echo -e "\e[31mlinux detected\e[0m"
    echo -e "\e[32minstalling apt picks\e[0m"
    # Use nightly nvim since most good features come after 0.7
    # and nvim on base apt is version 4.3
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo add-apt-repository universe
    sudo apt-get update
    sudo apt install neovim fswatch tmux ripgrep htop cmake python3 gnome-tweaks fd-find
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    # nvm install 22
    # nvm use 22
    # for fswatch neovim
    echo -e "fs.inotify.max_user_watches=100000\nfs.inotify.max_queued_events=100000" | sudo tee -a /etc/sysctl.conf
    dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"
    fonts_dir="$HOME/.fonts"
    mkdir -p "$fonts_dir"
    cd "$fonts_dir"
fi
if [ "$os" = "Darwin" ]; then
    echo -e "\e[31mmac detected\e[0m"
    echo -e "\e[32minstalling brew picks\e[0m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install neovim --HEAD
    # mac no longer ships newest bash install with homebrew
    brew install fswatch tmux ripgrep htop cmake wget python3 openssl bash
    brew install --cask karabiner-elements
    chsh -s /bin/bash
    echo "eval \"$(/opt/homebrew/bin/brew shellenv)\"" >> ~/.bashrc
    echo "export BASH_SILENCE_DEPRECATION_WARNING=1" >> ~/.bashrc
    # kitty not working on macos for me
    fonts_dir="/Library/Fonts/"
    mkdir -p $fonts_dir
    cd $fonts_dir
fi

echo -e "\e[32minstalling nerd font...\e[0m"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip && unzip "FiraCode" -d "$fonts_dir" && fc-cache -fv

echo -e "\e[32minstalling conda...\e[0m"
mkdir -p ~/Downloads
cd ~/Downloads
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh

echo -e "\e[33m************************************\e[0m"
echo -e "\e[32mfinished\e[0m"
echo -e "\e[32mrun finish_dev_env_setup.sh after opening new shell\e[0m"
echo -e "\e[33m************************************\e[0m"


source ~/.bashrc
