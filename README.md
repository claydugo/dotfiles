# Dotfiles

![20221228](dotfiles.png)

My auto-setup is currently using the script at `scripts/setup.sh`

```
❯ tree -a -I '.git|ramona'
.
├── .aliases
├── .bashrc
├── .config
│   ├── kitty
│   │   ├── diff.conf
│   │   ├── dracula.conf
│   │   └── kitty.conf
│   ├── nvim
│   │   ├── after
│   │   │   └── plugin
│   │   │       ├── cmp.lua
│   │   │       ├── colorscheme.lua
│   │   │       ├── lsp.lua
│   │   │       ├── lualine.lua
│   │   │       ├── one_line_setups.lua
│   │   │       ├── telescope.lua
│   │   │       └── treesitter.lua
│   │   ├── init.lua
│   │   ├── lua
│   │   │   ├── maps.lua
│   │   │   ├── pack.lua
│   │   │   └── settings.lua
│   │   └── plugin
│   │       └── packer_compiled.lua
│   └── starship.toml
├── dotfiles.png
├── .gitconfig
├── .gitignore
├── .gitmodules
├── .linux_aliases
├── .mac_aliases
├── README.md
├── scripts
│   └── setup.sh
├── .tmux.conf
└── .tmux-ssh.conf

8 directories, 28 files
```

#### Submodules

Clone with submodules:

`git clone --recurse-submodules -j8 git@github.com:claydugo/dotfiles.git`

after cloning:

`git submodule update --init`

after updates

`git submodule update --remote`

#### NVIM
nvim start time somewhere between 30ms - 70ms. With LSP and 20 plugins.

#### tmux
No plugins just mappings

