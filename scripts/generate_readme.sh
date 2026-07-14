#!/bin/bash

set -euo pipefail

# Stable sort order for tree output regardless of host locale
export LC_ALL=C

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR/.." || exit 1

for cmd in tree sed grep awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Error: %s not found\n' "$cmd" >&2
        exit 1
    fi
done

cat << 'HEADER'
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
HEADER

tree -a --gitignore --charset=utf-8 -I '.git|.jj|ramona|karabiner|.github|*.png|__pycache__|.ruff_cache' --noreport

cat << 'HEADER'
```

</details>

## Dependencies

Installed via `scripts/bootstrap.sh`:

### Pixi
HEADER

awk '
    /^(common|unix|linux|windows)_cli_tools=\(/ { in_array = 1 }
    in_array {
        line = $0
        sub(/^[a-z_]+=\(/, "", line)
        closed = sub(/\).*/, "", line)
        n = split(line, tools, /[ \t]+/)
        for (i = 1; i <= n; i++)
            if (tools[i] != "") printf "- `%s`\n", tools[i]
        if (closed) in_array = 0
    }
' scripts/bootstrap.sh

cat << 'FOOTER'

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
FOOTER
