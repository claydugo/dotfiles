#!/bin/bash

set -euo pipefail

# Stable sort order for tree output regardless of host locale
export LC_ALL=C

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR/.." || exit 1

for cmd in tree sed grep awk git; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Error: %s not found\n' "$cmd" >&2
        exit 1
    fi
done

tracked_files=$(git ls-files | wc -l | tr -d ' ')

cat << HEADER
# Dotfiles

![dotfiles](dotfiles.png)

## Installation

\`\`\`bash
git clone --recurse-submodules git@github.com:claydugo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh
\`\`\`

<details>
<summary>What <code>bootstrap.sh</code> does</summary>

\`\`\`mermaid
flowchart LR
    A[bootstrap.sh] --> B[Symlink configs<br>into \$HOME / XDG dirs]
    B --> C[Install terminal<br>Kitty / WezTerm]
    C --> D[Install Pixi]
    D --> E[pixi global install<br>CLI tools]
    E --> F[NVM + Node<br>Claude Code]
    F --> G[Neovim: restore plugins,<br>Treesitter parsers, Mason LSPs]
\`\`\`

Supports Linux, macOS, and Windows (MSYS2/Git Bash); OS-specific steps are skipped where they don't apply.

</details>

<details>
<summary>Structure ($tracked_files tracked files)</summary>

\`\`\`
HEADER

tree -a --gitignore --charset=utf-8 -I '.git|.jj|ramona|karabiner|.github|*.png|__pycache__|.ruff_cache' --noreport

cat << 'HEADER'
```

</details>

## Dependencies

Installed by `scripts/bootstrap.sh` via [`pixi global`](https://pixi.sh/latest/global_tools/introduction/):

| Tool | Linux | macOS | Windows |
| ---- | :---: | :---: | :-----: |
HEADER

awk '
    /^(common|unix|linux|windows)_cli_tools=\(/ {
        cat = $0
        sub(/_cli_tools=.*/, "", cat)
        in_array = 1
    }
    in_array {
        line = $0
        sub(/^[a-z_]+=\(/, "", line)
        closed = sub(/\).*/, "", line)
        n = split(line, tools, /[ \t]+/)
        for (i = 1; i <= n; i++)
            if (tools[i] != "") printf "%s\t%s\n", cat, tools[i]
        if (closed) in_array = 0
    }
' scripts/bootstrap.sh | while IFS=$'\t' read -r category pkg; do
    case "$category" in
        common)  cols="✅ | ✅ | ✅" ;;
        unix)    cols="✅ | ✅ | —" ;;
        linux)   cols="✅ | — | —" ;;
        windows) cols="— | — | ✅" ;;
    esac
    # shellcheck disable=SC2016  # backticks are markdown, not command substitution
    printf '| [`%s`](https://prefix.dev/channels/conda-forge/packages/%s) | %s |\n' "$pkg" "$pkg" "$cols"
done

cat << 'FOOTER'

### Other
- [Pixi](https://pixi.sh/)
- [NVM](https://github.com/nvm-sh/nvm) (Linux/macOS) / [fnm](https://github.com/Schniz/fnm) (Windows)
- [Claude Code](https://code.claude.com/docs/en/overview)
- [Kitty](https://sw.kovidgoyal.net/kitty/) (Linux/macOS) / [WezTerm](https://wezterm.org/) (Windows)
- [Google Sans Code Nerd Font](https://github.com/AliApg/GoogleSansCode-Nerd)

## Neovim
FOOTER

plugins=$(
    grep -rhoP 'https://github\.com/[A-Za-z0-9_-]+/[A-Za-z0-9._-]+' \
        .config/nvim/lua/plugins .config/nvim/lua/config |
        sed -e 's|https://github.com/||' -e 's|\.git$||' | sort -fu
)
plugin_count=$(printf '%s\n' "$plugins" | grep -c .)

printf '\n<details>\n<summary>Plugins (%s, managed by <a href="https://neovim.io/doc/user/pack.html#vim.pack">vim.pack</a>)</summary>\n\n' "$plugin_count"
printf '%s\n' "$plugins" | awk -F/ '{ printf "- [%s](https://github.com/%s) by `%s`\n", $2, $0, $1 }'
printf '\n</details>\n'

awk '
    /^M\.treesitter = \{/ { list = "treesitter"; next }
    /^M\.mason = \{/      { list = "mason"; next }
    /^\}/                 { list = "" }
    list && match($0, /"[^"]+"/) {
        printf "%s\t%s\n", list, substr($0, RSTART + 1, RLENGTH - 2)
    }
' .config/nvim/lua/packages.lua | awk -F'\t' '
    { items[$1] = items[$1] (items[$1] ? ", " : "") "`" $2 "`" }
    END {
        printf "\n**Treesitter parsers:** %s\n", items["treesitter"]
        printf "\n**Mason packages:** %s\n", items["mason"]
    }
'

cat << 'FOOTER'

## Submodules

```bash
# After cloning
git submodule update --init

# To update submodules
git submodule update --remote
```
FOOTER
