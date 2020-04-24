############################
#     .zshrc - 11/10/19    #
#      - Clay Dugo -       #
#  dotfiles@m.claydugo.com #
############################

export ZSH="/Users/clay/.oh-my-zsh"
export EDITOR="nvim"

# https://github.com/mkolosick/agnoster-light/blob/master/agnoster-light.zsh-theme
ZSH_THEME="agnoster-light" 
COMPLETION_WAITING_DOTS="true"

source $ZSH/oh-my-zsh.sh


if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi

source ~/dotfiles/.aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(thefuck --alias)
