# Dotfiles

![20221228](dotfiles.png)

My auto-setup is currently using the script at `scripts/setup.sh`

```
.
├── .aliases
├── .bashrc
├── .config
│   ├── kitty
│   │   ├── diff.conf
│   │   ├── dracula.conf
│   │   └── kitty.conf
│   ├── nvim
│   │   ├── init.lua
│   │   ├── lazy-lock.json
│   │   └── lua
│   │       ├── config
│   │       │   ├── lazy.lua
│   │       │   ├── maps.lua
│   │       │   ├── options.lua
│   │       │   └── plugins
│   │       │       ├── gitsigns.lua
│   │       │       ├── lsp.lua
│   │       │       ├── lualine.lua
│   │       │       ├── nvim-comment.lua
│   │       │       ├── telescope.lua
│   │       │       ├── tokyonight.lua
│   │       │       ├── treesitter.lua
│   │       │       └── vimwiki.lua
│   │       └── init.lua
│   └── starship.toml
├── dotfiles.png
├── .gitignore
├── .gitmodules
├── .linux_aliases
├── .mac_aliases
├── README.md
├── scripts
│   └── setup.sh
├── .tmux.conf
├── .tmux-ssh.conf
└── .xprofile

7 directories, 30 files

```

#### Submodules

Clone with submodules:

`git clone --recurse-submodules -j8 git@github.com:claydugo/dotfiles.git`

after cloning:

`git submodule update --init`

after updates

`git submodule update --remote`

#### NVIM
nvim start time somewhere between 15ms - 20ms.

#### tmux
No plugins just mappings

#### Old NVIM configurations

[Switch from init.vim to init.lua](https://github.com/claydugo/dotfiles/commit/9803e70ab5df4f5db7f9da858a3c670d378daf0b)

[Switch from packer.nvim to lazy.nvim](https://github.com/claydugo/dotfiles/commit/00000000a6b60527c21ba36515c93c71869ae253)
