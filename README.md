# Dotfiles

![dotfiles](dotfiles.png)

## Installation

```bash
git clone --recurse-submodules git@github.com:claydugo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh
```

<details>
<summary>Structure</summary>

```
.
├── .aliases
├── .bashrc
├── .claude
│   ├── commands
│   │   ├── interview.md
│   │   ├── jj.md
│   │   ├── luaist.md
│   │   ├── pythonista.md
│   │   ├── rebase.md
│   │   └── remove_slop.md
│   ├── output-styles
│   │   └── direct-action.md
│   ├── settings.json
│   └── statusline.sh
├── .config
│   ├── .ripgreprc
│   ├── jj
│   │   └── config.toml
│   ├── kitty
│   │   └── kitty.conf
│   ├── nvim
│   │   ├── .luarc.json
│   │   ├── bin
│   │   │   └── zig-cc.cmd
│   │   ├── ftplugin
│   │   │   └── lua.lua
│   │   ├── init.lua
│   │   ├── lua
│   │   │   ├── config
│   │   │   │   └── lazy.lua
│   │   │   ├── headless_install.lua
│   │   │   ├── langserver_icons.lua
│   │   │   ├── maps.lua
│   │   │   ├── options.lua
│   │   │   ├── packages.lua
│   │   │   └── plugins
│   │   │       ├── blink-cmp.lua
│   │   │       ├── browsher.lua
│   │   │       ├── dropbar.lua
│   │   │       ├── gitsigns.lua
│   │   │       ├── harpoon.lua
│   │   │       ├── lazydev.lua
│   │   │       ├── lsp.lua
│   │   │       ├── lualine.lua
│   │   │       ├── markdown.lua
│   │   │       ├── mini.lua
│   │   │       ├── noice.lua
│   │   │       ├── showtime.lua
│   │   │       ├── snacks.lua
│   │   │       ├── telescope.lua
│   │   │       ├── tip_of_my_buffer.lua
│   │   │       ├── tokyonight.lua
│   │   │       └── treesitter.lua
│   │   └── spell
│   │       └── en.utf-8.add
│   ├── starship.toml
│   └── wezterm
│       └── wezterm.lua
├── .gitattributes
├── .gitconfig
├── .gitignore
├── .gitlab_ci_skip
├── .gitmodules
├── .ipython
│   ├── __init__.py
│   └── profile_default
│       └── startup
│           └── 00-conf.py
├── .local
│   └── bin
│       └── build_nvim.sh
├── .pre-commit-config.yaml
├── .stylua.toml
├── .tmux.conf
├── .yamlfmt
├── README.md
├── scripts
│   ├── bootstrap.sh
│   ├── generate_readme.sh
│   └── install_google_sans_code.sh
├── selene.toml
└── vim.yml
```

</details>

## Dependencies

Installed via `scripts/bootstrap.sh`:

### Pixi
- `nvim`
- `starship`
- `eza`
- `bat`
- `fzf`
- `ripgrep`
- `fd-find`
- `cmake`
- `make`
- `openssl`
- `rattler-build`
- `stylua`
- `selene`
- `jujutsu`
- `hyperfine`
- `tree-sitter-cli`
- `ty`
- `bash`
- `git`
- `curl`
- `tmux`
- `htop`
- `wget`
- `unzip`
- `fastfetch`
- `xclip`
- `fswatch`
- `gifski`
- `zig`
- `fnm`
- `ninja`

### Other
- [Pixi](https://pixi.sh/)
- [NVM](https://github.com/nvm-sh/nvm)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [Google Sans Code Nerd Font](https://github.com/AliApg/GoogleSansCode-Nerd)

## Submodules

```bash
# After cloning
git submodule update --init

# To update submodules
git submodule update --remote
```
