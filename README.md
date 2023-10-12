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
│   │       ├── config
│   │       │   ├── langserver_icons.lua
│   │       │   ├── lazy.lua
│   │       │   ├── maps.lua
│   │       │   ├── options.lua
│   │       │   └── plugin_maps.lua
│   │       └── plugins
│   │           ├── copilot.lua
│   │           ├── gitsigns.lua
│   │           ├── lsp.lua
│   │           ├── lualine.lua
│   │           ├── mini.lua
│   │           ├── nvim-comment.bak
│   │           ├── telescope.lua
│   │           ├── tokyonight.lua
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

9 directories, 33 files
```

#### Dependencies
* [neovim](https://neovim.io/)
* [tmux](https://github.com/tmux/tmux/wiki)
* [starship](https://starship.rs)
* [exa](https://the.exa.website/)
* [watchman](https://facebook.github.io/watchman/) because [nvim's watchfiles implementation is bad and pyright is greedy](.config/nvim/lua/plugins/lsp.lua)

#### Submodules

Clone with submodules:

`git clone --recurse-submodules -j8 git@github.com:claydugo/dotfiles.git`

after cloning:

`git submodule update --init`

after updates

`git submodule update --remote`

#### Old NVIM configurations

[Switch from init.vim to init.lua](https://github.com/claydugo/dotfiles/commit/9803e70ab5df4f5db7f9da858a3c670d378daf0b)

[Switch from packer.nvim to lazy.nvim](https://github.com/claydugo/dotfiles/commit/00000000a6b60527c21ba36515c93c71869ae253)
