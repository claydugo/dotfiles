# Dotfiles

![20221228](dotfiles.png)

![20221228](dots_macos.png)

My auto-installer is located at `scripts/setup.sh`

```
$ tree -a -I '.git|ramona|karabiner'
.
├── .aliases
├── .bashrc
├── .config
│   ├── alacritty
│   │   └── alacritty.yml
│   ├── kitty
│   │   └── kitty.conf
│   ├── nvim
│   │   ├── init.lua
│   │   ├── lazy-lock.json
│   │   └── lua
│   │       ├── config
│   │       │   ├── langserver_icons.lua
│   │       │   ├── lazy.lua
│   │       │   ├── maps.lua
│   │       │   └── options.lua
│   │       └── plugins
│   │           ├── copilot.lua
│   │           ├── gitsigns.lua
│   │           ├── lsp.lua
│   │           ├── lualine.lua
│   │           ├── nvim-comment.lua
│   │           ├── smartcolumn.lua
│   │           ├── telescope.lua
│   │           ├── tokyonight.lua
│   │           ├── treesitter.lua
│   │           ├── undotree.lua
│   │           └── vimwiki.lua
│   └── starship.toml
├── dotfiles.png
├── dots_macos.png
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

8 directories, 33 files
```

#### Submodules

Clone with submodules:

`git clone --recurse-submodules -j8 git@github.com:claydugo/dotfiles.git`

after cloning:

`git submodule update --init`

after updates

`git submodule update --remote`

#### NVIM
nvim start time somewhere between 3 - 5ms.

#### Old NVIM configurations

[Switch from init.vim to init.lua](https://github.com/claydugo/dotfiles/commit/9803e70ab5df4f5db7f9da858a3c670d378daf0b)

[Switch from packer.nvim to lazy.nvim](https://github.com/claydugo/dotfiles/commit/00000000a6b60527c21ba36515c93c71869ae253)
