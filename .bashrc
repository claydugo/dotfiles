export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

shopt -s histappend
HISTIGNORE="&:[ ]*:exit:e:R:tmux.*:cd:la:ls:ll:lll:c:history:clear:cl:v:t:p:\:..:...:....:q"
HISTCONTROL=ignoreboth
HISTSIZE=50000
HISTFILESIZE=100000
HISTFILE="$XDG_STATE_HOME/bash/history"

shopt -s checkwinsize
shopt -s cdspell
shopt -s dirspell
shopt -s globstar 2>/dev/null

set -o vi

if hash nvim 2>/dev/null; then
  export EDITOR=nvim
elif hash vim 2>/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi
export USE_EDITOR="$EDITOR"
export VISUAL="$EDITOR"

# Try new ssh specific leader
if [[ -n $SSH_CONNECTION ]] && command -v tmux >/dev/null 2>&1; then
#     tmux attach || tmux new
    [[ -f ~/dotfiles/.tmux-ssh.conf ]] && tmux source-file ~/dotfiles/.tmux-ssh.conf 2>/dev/null
fi

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

path_prepend "$HOME/.cargo/bin"
path_prepend "/usr/lib/qt6/bin"

if [[ -f "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

if hash starship 2>/dev/null; then
    eval "$(starship init bash)"
fi

path_prepend "$HOME/.pixi/bin"

os=$(uname -s)

if [[ "$os" = "Linux" ]]; then
    source "$HOME/dotfiles/.linux_aliases"
fi
if [[ "$os" = "Darwin" ]]; then
    source "$HOME/dotfiles/.mac_aliases"
fi

source "$HOME/dotfiles/.aliases"

export NVM_DIR="$XDG_DATA_HOME/nvm"
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
fi

export PYGFX_PRINT_WGSL_ON_COMPILATION_ERROR=1
export PATH
