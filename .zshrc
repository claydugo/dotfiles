############################
#     .zshrc - 09/19/20    #
############################

export ZSH="/Users/clay/.oh-my-zsh"
export EDITOR="nvim"

# https://github.com/mkolosick/agnoster-light/blob/master/agnoster-light.zsh-theme
ZSH_THEME="agnoster" 
COMPLETION_WAITING_DOTS="true"

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi

source ~/dotfiles/.aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# opam configuration
test -r /Users/clay/.opam/opam-init/init.zsh && . /Users/clay/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/bin:$PATH"
