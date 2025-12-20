#!/bin/bash

set -e
cd "$(dirname "$0")/.."

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

tree -a -I '.git|ramona|karabiner|.github|*.png|__pycache__|.ruff_cache' --noreport

cat << 'HEADER'
```

</details>

## Dependencies

Installed via `scripts/bootstrap.sh`:

### Cargo Packages
HEADER

grep "cargo binstall" scripts/bootstrap.sh | while read -r line; do
    pkg=$(echo "$line" | sed 's/#.*//; s/||.*//' | grep -oE '[a-z][-a-z0-9]*' | tail -1)
    echo "- \`$pkg\`"
done

cat << 'HEADER'

### Pixi
HEADER

sed -n '/^global_cli_tools=(/,/^)/p' scripts/bootstrap.sh | grep -E '^\s+[a-z]' | while read -r line; do
    pkg=$(echo "$line" | awk '{print $1}')
    echo "- \`$pkg\`"
done

cat << 'HEADER'

### Linux Desktop Packages (apt)
HEADER

sed -n '/^linux_desktop_packages=(/,/^)/p' scripts/bootstrap.sh | grep -E '^\s+[a-z]' | while read -r line; do
    pkg=$(echo "$line" | awk '{print $1}')
    echo "- \`$pkg\`"
done

cat << 'FOOTER'

### Other
- [Pixi](https://pixi.sh/)
- [rustup](https://rustup.rs/)
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
