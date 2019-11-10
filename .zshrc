############################
#     .zshrc - 11/09/19    #
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
  export EDITOR='mvim'
fi


alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ls='ls -la'
alias lsg='ls | grep'
alias cl='clear'
alias md='mkdir'
alias zrc="nvim ~/.zshrc"
alias vrc="nvim ~/.vimrc"
alias trc="nvim ~/.tmux.conf"
alias dotfiles="cd  ~/dotfiles/"
alias top="htop"
alias qq="exit"
alias :q='exit'
alias f="open ."
alias p="python3"
alias v="nvim"
alias t="tmux"
alias gpm="git push -u origin master"
alias gc="git commit -m" # handling gpg signing thru .gitconfig now
alias gcr="git commit --reuse-message=HEAD" # reuse last commit message
alias ga="git add"
alias gs="git status -s"
alias gsl="git status"
alias gd="git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat"
alias brewu='brew update && brew upgrade && brew cleanup && brew doctor'
alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(thefuck --alias)
