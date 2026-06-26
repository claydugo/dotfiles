# shellcheck shell=bash
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

shopt -s histappend
HISTIGNORE="&:ls:la:ll:lll:cd:exit:clear:cl:history:q:..:...:....:\:"
HISTCONTROL=ignoredups
HISTSIZE=50000
HISTFILESIZE=100000
HISTFILE="$XDG_STATE_HOME/bash/history"

shopt -s checkwinsize
shopt -s cdspell
shopt -s dirspell
shopt -s globstar 2>/dev/null

set -o vi

# kitty doesnt work well with tmux
if [[ ${TERM} == "xterm-kitty" ]]; then
    export TERM=xterm-256color
fi

if [ -f "$XDG_CONFIG_HOME/.ripgreprc" ]; then
    export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/.ripgreprc"
fi

# tab completion no longer case sensitive
# needs wrapper to avoid login warning
if [[ -t 1 ]]; then
    bind 'set completion-ignore-case on'
fi

path_prepend() {
    local dir="$1"
    [[ -n "$dir" ]] || return
    case ":$PATH:" in
        *:"$dir":*) ;;
        *) PATH="$dir${PATH:+:$PATH}" ;;
    esac
}

if [[ -f "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

export BUN_INSTALL="$HOME/.bun"

path_prepend "$HOME/.cargo/bin"
path_prepend "/usr/lib/qt6/bin"
path_prepend "$HOME/.pixi/bin"
path_prepend "$BUN_INSTALL/bin"
path_prepend "$HOME/go/bin"
path_prepend "$HOME/.local/bin"

if [[ -n "$MSYSTEM" ]]; then
    for _d in /usr/bin /bin /mingw64/bin; do
        case ":$PATH:" in *":$_d:"*) ;; *) PATH="$PATH:$_d" ;; esac
    done
    unset _d
fi

if hash nvim 2>/dev/null; then
  export EDITOR=nvim
elif hash vim 2>/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi
export USE_EDITOR="$EDITOR"
export VISUAL="$EDITOR"

if hash fzf 2>/dev/null; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi

if hash starship 2>/dev/null; then
    eval "$(starship init bash)"
fi

source "$HOME/dotfiles/.aliases"

export NVM_DIR="$XDG_DATA_HOME/nvm"
if [[ -n "$MSYSTEM" ]]; then
    # Git Bash's login profile aliases node/npm/etc. to winpty wrappers, which
    # collide with the function definitions below at parse time (syntax error).
    unalias node npm nvm 2>/dev/null || true
fi
if [ -s "$NVM_DIR/nvm.sh" ]; then
    node() {
        unset -f node npm nvm
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
        node "$@"
    }
    npm() {
        unset -f node npm nvm
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
        npm "$@"
    }
    nvm() {
        unset -f node npm nvm
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
        nvm "$@"
    }
elif [[ -n "$MSYSTEM" ]] && hash fnm 2>/dev/null; then
    # Windows uses fnm (not nvm). Skip if nvm is wired up so we don't double-init.
    eval "$(fnm env --use-on-cd)"
fi

export PYGFX_PRINT_WGSL_ON_COMPILATION_ERROR=1
export RUST_BACKTRACE=full
if [[ "$(uname)" == "Linux" ]]; then
    export QT_QPA_PLATFORMTHEME=gtk3
    export QT_QPA_PLATFORM=wayland
fi
