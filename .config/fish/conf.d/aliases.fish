# Fish-specific aliases and conditional setups

# Path alias
alias path='echo $PATH | tr " " "\n"'

# Tmux session with hostname
alias t='tmux new-session -s (hostname)'

# Temp directory
function td
    cd (mktemp -d /tmp/$argv[1].XXX)
end

# Git clean branches
alias git_clean='git branch | grep -v "main" | grep -v "master" | xargs git branch -D'


# eza (modern ls replacement)
if type -q eza
    alias ls='eza'
    alias ll="eza -lah --git --icons"
    alias lll="eza -abghHliS@ --git --icons"
end

# bat (modern cat with syntax highlighting)
alias la='cat ~/dotfiles/.aliases'
if type -q bat
    alias la='bat ~/.aliases -l bash'
end

# nvim aliases
if type -q nvim
    alias vim='nvim'
    alias vi='nvim'
    alias vimdiff='nvim -d'
end
