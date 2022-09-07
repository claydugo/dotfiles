shopt -s histappend
HISTIGNORE="&:[ ]*:exit:e:R:make:tmux.*:cd:la:ls:ll:gd:gs:c:history:clear:cl:v:t:\:q"
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

if [[ -n $SSH_CONNECTION ]] ; then
    tmux attach || tmux new
fi

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

#export TERM="xterm-256color"

# trying bash-git-prompt per Jed's welcome doc
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    if [[ "$SSH_CONNECTION" != "" ]]; then
	    	GIT_PROMPT_END_USER=" \n${Green}${USER}@${HOSTNAME%%.*}${ResetColor} $ "
	  fi  
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.bash-git-prompt/gitprompt.sh
fi

# cargo path
export PATH=/home/clay/.cargo/bin:$PATH
