############################
#     .zshrc - 10/16/19    #
#       -Clay Dugo-        #
#  dotfiles@m.claydugo.com #
############################

export ZSH="/Users/clay/.oh-my-zsh"
export EDITOR="nvim"


ZSH_THEME="agnoster-light"  # https://github.com/mkolosick/agnoster-light/blob/master/agnoster-light.zsh-theme
COMPLETION_WAITING_DOTS="true"
# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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
  export EDITOR='mvim'
fi


alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ls='ls -la'
alias md='mkdir'
alias cl='clear'
alias zshrc="nvim ~/.zshrc"
alias vimrc="nvim ~/.vimrc"
alias tmuxrc="nvim ~/.tmux.conf"
alias top="htop"
alias qq="exit"
alias f="open ."
alias p="python3"
alias v="nvim"
alias t="tmux"
alias gpm="git push -u origin master"
alias gc="git commit -S -m"
alias ga="git add"
alias gra="git remote add origin" #git remote add origin https://github.com/claydugo/git-cheatsheat.git


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(thefuck --alias)
