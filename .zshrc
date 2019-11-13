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
plugins=(
	git
	pip
	autopep8
	brew
	python
	tmux
	osx
	)

source $ZSH/oh-my-zsh.sh

ZSH_TMUX_AUTOSTART="true"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

source ~/dotfiles/.aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(thefuck --alias)
