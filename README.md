# Dotfiles

![dotfiles](dotfiles.png)

## Installation

```bash
git clone --recurse-submodules git@github.com:claydugo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh
```

<details>
<summary>What <code>bootstrap.sh</code> does</summary>

```mermaid
flowchart LR
    A[bootstrap.sh] --> B[Symlink configs<br>into $HOME / XDG dirs]
    B --> C[Install terminal<br>Kitty / WezTerm]
    C --> D[Install Pixi]
    D --> E[pixi global install<br>CLI tools]
    E --> F[NVM + Node<br>Claude Code]
    F --> G[Neovim: restore plugins,<br>Treesitter parsers, Mason LSPs]
```

Supports Linux, macOS, and Windows (MSYS2/Git Bash); OS-specific steps are skipped where they don't apply.

</details>

<details>
<summary>Structure (78 tracked files)</summary>

```
.
├── .aliases
├── .bashrc
├── .claude
│   ├── CLAUDE.md
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
│   │   ├── after
│   │   │   └── queries
│   │   │       └── jinja
│   │   │           └── injections.scm
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

Installed by `scripts/bootstrap.sh` via [`pixi global`](https://pixi.sh/latest/global_tools/introduction/):

| Tool | Linux | macOS | Windows |
| ---- | :---: | :---: | :-----: |
| [`nvim`](https://prefix.dev/channels/conda-forge/packages/nvim) | ✅ | ✅ | ✅ |
| [`starship`](https://prefix.dev/channels/conda-forge/packages/starship) | ✅ | ✅ | ✅ |
| [`eza`](https://prefix.dev/channels/conda-forge/packages/eza) | ✅ | ✅ | ✅ |
| [`bat`](https://prefix.dev/channels/conda-forge/packages/bat) | ✅ | ✅ | ✅ |
| [`fzf`](https://prefix.dev/channels/conda-forge/packages/fzf) | ✅ | ✅ | ✅ |
| [`ripgrep`](https://prefix.dev/channels/conda-forge/packages/ripgrep) | ✅ | ✅ | ✅ |
| [`fd-find`](https://prefix.dev/channels/conda-forge/packages/fd-find) | ✅ | ✅ | ✅ |
| [`cmake`](https://prefix.dev/channels/conda-forge/packages/cmake) | ✅ | ✅ | ✅ |
| [`make`](https://prefix.dev/channels/conda-forge/packages/make) | ✅ | ✅ | ✅ |
| [`openssl`](https://prefix.dev/channels/conda-forge/packages/openssl) | ✅ | ✅ | ✅ |
| [`rattler-build`](https://prefix.dev/channels/conda-forge/packages/rattler-build) | ✅ | ✅ | ✅ |
| [`stylua`](https://prefix.dev/channels/conda-forge/packages/stylua) | ✅ | ✅ | ✅ |
| [`selene`](https://prefix.dev/channels/conda-forge/packages/selene) | ✅ | ✅ | ✅ |
| [`jujutsu`](https://prefix.dev/channels/conda-forge/packages/jujutsu) | ✅ | ✅ | ✅ |
| [`hyperfine`](https://prefix.dev/channels/conda-forge/packages/hyperfine) | ✅ | ✅ | ✅ |
| [`tree-sitter-cli`](https://prefix.dev/channels/conda-forge/packages/tree-sitter-cli) | ✅ | ✅ | ✅ |
| [`ty`](https://prefix.dev/channels/conda-forge/packages/ty) | ✅ | ✅ | ✅ |
| [`bash`](https://prefix.dev/channels/conda-forge/packages/bash) | ✅ | ✅ | — |
| [`git`](https://prefix.dev/channels/conda-forge/packages/git) | ✅ | ✅ | — |
| [`curl`](https://prefix.dev/channels/conda-forge/packages/curl) | ✅ | ✅ | — |
| [`tmux`](https://prefix.dev/channels/conda-forge/packages/tmux) | ✅ | ✅ | — |
| [`htop`](https://prefix.dev/channels/conda-forge/packages/htop) | ✅ | ✅ | — |
| [`wget`](https://prefix.dev/channels/conda-forge/packages/wget) | ✅ | ✅ | — |
| [`unzip`](https://prefix.dev/channels/conda-forge/packages/unzip) | ✅ | ✅ | — |
| [`fastfetch`](https://prefix.dev/channels/conda-forge/packages/fastfetch) | ✅ | ✅ | — |
| [`xclip`](https://prefix.dev/channels/conda-forge/packages/xclip) | ✅ | — | — |
| [`fswatch`](https://prefix.dev/channels/conda-forge/packages/fswatch) | ✅ | — | — |
| [`gifski`](https://prefix.dev/channels/conda-forge/packages/gifski) | ✅ | — | — |
| [`zig`](https://prefix.dev/channels/conda-forge/packages/zig) | — | — | ✅ |
| [`fnm`](https://prefix.dev/channels/conda-forge/packages/fnm) | — | — | ✅ |
| [`ninja`](https://prefix.dev/channels/conda-forge/packages/ninja) | — | — | ✅ |

### Other
- [Pixi](https://pixi.sh/)
- [NVM](https://github.com/nvm-sh/nvm) (Linux/macOS) / [fnm](https://github.com/Schniz/fnm) (Windows)
- [Claude Code](https://code.claude.com/docs/en/overview)
- [Kitty](https://sw.kovidgoyal.net/kitty/) (Linux/macOS) / [WezTerm](https://wezterm.org/) (Windows)
- [Google Sans Code Nerd Font](https://github.com/AliApg/GoogleSansCode-Nerd)

## Neovim

<details>
<summary>Plugins (30, managed by <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a>)</summary>

- [luvit-meta](https://github.com/Bilal2453/luvit-meta) by `Bilal2453`
- [browsher.nvim](https://github.com/claydugo/browsher.nvim) by `claydugo`
- [dropbar.nvim](https://github.com/claydugo/dropbar.nvim) by `claydugo`
- [showtime.nvim](https://github.com/claydugo/showtime.nvim) by `claydugo`
- [tip_of_my_buffer.nvim](https://github.com/claydugo/tip_of_my_buffer.nvim) by `claydugo`
- [telescope-undo.nvim](https://github.com/debugloop/telescope-undo.nvim) by `debugloop`
- [mini.nvim](https://github.com/echasnovski/mini.nvim) by `echasnovski`
- [lazy.nvim](https://github.com/folke/lazy.nvim) by `folke`
- [lazydev.nvim](https://github.com/folke/lazydev.nvim) by `folke`
- [noice.nvim](https://github.com/folke/noice.nvim) by `folke`
- [snacks.nvim](https://github.com/folke/snacks.nvim) by `folke`
- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) by `folke`
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) by `lewis6991`
- [mason.nvim](https://github.com/mason-org/mason.nvim) by `mason-org`
- [markdown.nvim](https://github.com/MeanderingProgrammer/markdown.nvim) by `MeanderingProgrammer`
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) by `MunifTanjim`
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) by `neovim`
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) by `nvim-lua`
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) by `nvim-lualine`
- [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) by `nvim-telescope`
- [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim) by `nvim-telescope`
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) by `nvim-telescope`
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) by `nvim-tree`
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) by `nvim-treesitter`
- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) by `nvim-treesitter`
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) by `rafamadriz`
- [nvim-notify](https://github.com/rcarriga/nvim-notify) by `rcarriga`
- [blink.cmp](https://github.com/saghen/blink.cmp) by `saghen`
- [harpoon](https://github.com/ThePrimeagen/harpoon) by `ThePrimeagen`
- [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) by `windwp`

</details>

**Treesitter parsers:** `python`, `lua`, `wgsl`, `cuda`, `rust`, `c`, `bash`, `html`, `markdown`, `markdown_inline`, `json`, `toml`, `yaml`, `jinja`, `jinja_inline`, `qmldir`, `luadoc`, `desktop`, `tmux`, `ssh_config`, `git_config`, `git_rebase`, `gitattributes`, `gitcommit`, `gitignore`

**Mason packages:** `biome`, `harper-ls`, `bash-language-server`, `copilot-language-server`, `emmylua_ls`, `rust-analyzer`, `shellcheck`, `wgsl-analyzer`, `clangd`, `taplo`, `yaml-language-server`

## Submodules

```bash
# After cloning
git submodule update --init

# To update submodules
git submodule update --remote
```
