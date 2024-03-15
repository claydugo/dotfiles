#!/usr/bin/env bash
cd $HOME/git/upstream/neovim

git pull

sudo rm -rf /usr/local/share/nvim
sudo make distclean

sudo make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
