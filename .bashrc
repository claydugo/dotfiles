shopt -s histappend
HISTIGNORE="&:[ ]*:exit:e:R:make:tmux.*:cd:la:ls:ll:gd:gs:c:history:clear:cl:v:t:p:cd:\:..:...:....:q"
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

set -o vi
set editing-mode vi
set keymap vi

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

conda_dir=$HOME

if [ -d "$HOME/miniforge3/" ]; then
    conda_dir=$HOME/miniforge3/
fi

if [ -d "$HOME/mambaforge/" ]; then
    conda_dir=$HOME/mambaforge/
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$conda_dir/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$conda_dir/etc/profile.d/conda.sh" ]; then
        . "$conda_dir/etc/profile.d/conda.sh"
    else
        export PATH="$conda_dir/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "$conda_dir/etc/profile.d/mamba.sh" ]; then
    . "$conda_dir/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

# tab completion no longer case sensitive
# needs wrapper to avoid login warning
if [ -t 1 ]; then
    bind 'set completion-ignore-case on'
fi

os=$(uname -s)

if [ "$os" = "Linux" ]; then
    source ~/dotfiles/.linux_aliases
fi
if [ "$os" = "Darwin" ]; then
    source ~/dotfiles/.mac_aliases
fi

# import aliases
source ~/dotfiles/.aliases

# cargo path
export PATH=/home/clay/.cargo/bin:$PATH


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


. "$HOME/.cargo/env"

export BASH_SILENCE_DEPRECATION_WARNING=1
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init bash)"
