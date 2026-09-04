#!/bin/bash

set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

environment_prefix=$(pixi info --manifest-path "$HOME/pixi.toml" --json |
    jq -er '.environments_info[] | select(.name == "default") | .prefix' |
    head -n 1)
if [[ -n ${MSYSTEM:-} ]]; then
    environment_prefix=$(cygpath -u "$environment_prefix")
fi
for interpreter in "$environment_prefix/bin/python" "$environment_prefix/python.exe"; do
    if [ -x "$interpreter" ]; then
        exec "$interpreter" "$@"
    fi
done
printf 'Pixi default environment has no Python executable: %s\n' "$environment_prefix" >&2
exit 1
