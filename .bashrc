export XDG_CONFIG_HOME="$HOME/.config"

shopt -s histappend
HISTIGNORE="&:[ ]*:exit:e:R:tmux.*:cd:la:ls:ll:lll:c:history:clear:cl:v:t:p:\:..:...:....:q"
HISTCONTROL=ignoreboth
HISTSIZE=50000
HISTFILESIZE=100000

set -o vi
set editing-mode vi

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
if [[ -n $SSH_CONNECTION ]] ; then
#     tmux attach || tmux new
    tmux source-file ~/dotfiles/.tmux-ssh.conf
fi

# kitty doesnt work well with tmux
if [[ ${TERM} == "xterm-kitty" ]]; then
    export TERM=xterm-256color
fi

if [ -f "$XDG_CONFIG_HOME/.ripgreprc" ]; then
    export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/.ripgreprc"
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

ZIGENV_ROOT="$HOME/.zigenv"
path_prepend "$ZIGENV_ROOT/bin"
path_prepend "$ZIGENV_ROOT/shims"
export ZIGENV_ROOT

if [[ -f "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

if hash starship 2>/dev/null; then
    eval "$(starship init bash)"
fi

conda_dir=$HOME

if [[ -d "$HOME/miniforge3/" ]]; then
    conda_dir=$HOME/miniforge3/
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/clay/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/clay/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/clay/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/clay/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
#
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/home/clay/miniforge3/condabin/mamba';
export MAMBA_ROOT_PREFIX='/home/clay/miniforge3';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

path_prepend "$HOME/.pixi/bin"
export PATH

# tab completion no longer case sensitive
# needs wrapper to avoid login warning
if [[ -t 1 ]]; then
    bind 'set completion-ignore-case on'
fi

os=$(uname -s)

if [[ "$os" = "Linux" ]]; then
    source ~/dotfiles/.linux_aliases
fi
if [[ "$os" = "Darwin" ]]; then
    source ~/dotfiles/.mac_aliases
fi

source ~/dotfiles/.aliases
PYGFX_PRINT_WGSL_ON_COMPILATION_ERROR=1


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
