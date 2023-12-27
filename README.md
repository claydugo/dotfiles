# Dotfiles

![20221228](dotfiles.png)

![20221228](dots_macos.png)

My auto-installer is located at `scripts/setup.sh`

```bash

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
│   │       ├── langserver_icons.lua
│   │       ├── lazy_manager.lua
│   │       ├── maps.lua
│   │       ├── maps_plugin.lua
│   │       ├── options.lua
│   │       └── plugins
│   │           ├── copilot.lua
│   │           ├── github_theme.lua
│   │           ├── gitsigns.lua
│   │           ├── lsp.lua
│   │           ├── lualine.lua
│   │           ├── mini.lua
│   │           ├── telescope.lua
│   │           ├── treesitter.lua
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

8 directories, 32 files
```

#### Dependencies
* [neovim](https://neovim.io/)
* [tmux](https://github.com/tmux/tmux/wiki)
* [starship](https://starship.rs)
* [exa](https://the.exa.website/)

#### Submodules

Clone with submodules:

`git clone --recurse-submodules -j8 git@github.com:claydugo/dotfiles.git`

after cloning:

`git submodule update --init`

after updates

`git submodule update --remote`

#### Old NVIM configurations

[Custom Bubble Theme](https://github.com/claydugo/dotfiles/tree/c3a7fd79d0722f6af88129d9861a21a8f20ef223)

[Switch from init.vim to init.lua](https://github.com/claydugo/dotfiles/commit/9803e70ab5df4f5db7f9da858a3c670d378daf0b)

[Switch from packer.nvim to lazy.nvim](https://github.com/claydugo/dotfiles/commit/00000000a6b60527c21ba36515c93c71869ae253)

