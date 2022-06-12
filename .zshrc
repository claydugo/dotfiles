############################
#     .zshrc - 10/13/21    #
############################

export ZSH="/Users/clay/.oh-my-zsh"
export EDITOR="nvim"
export PYTHONPATH="/usr/local/Cellar/python/3.9.0/bin/python3:$PYTHONPATH"

# https://github.com/mkolosick/agnoster-light/blob/master/agnoster-light.zsh-theme
#ZSH_THEME="agnoster" 
ZSH_THEME="robbyrussell" 

COMPLETION_WAITING_DOTS="true"

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi

source ~/dotfiles/.aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# edits do not persist through sudo updates
enable-sudo-touchid() {
    sudo sed -i -e '1s;^;auth       sufficient     pam_tid.so\n;' /etc/pam.d/sudo
}

# opam configuration
test -r /Users/clay/.opam/opam-init/init.zsh && . /Users/clay/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Created by `userpath` on 2021-01-18 16:08:27
export PATH="$PATH:/Users/clay/.local/bin"

export PATH="$PATH:/Users/clay/.cargo/bin"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/clay/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/clay/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/clay/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/clay/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/opt/homebrew/sbin:$PATH"
