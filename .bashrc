[ -f ~/.fzf.bash ] && source ~/.fzf.bash

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
