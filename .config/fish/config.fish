set -g fish_greeting

fish_vi_key_bindings

set -gx fish_history_size 1000

if type -q nvim
    set -gx EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end
set -gx USE_EDITOR $EDITOR
set -gx VISUAL $EDITOR

if test -n "$SSH_CONNECTION"
    tmux source-file ~/dotfiles/.tmux-ssh.conf
end

if test "$TERM" = "xterm-kitty"
    set -gx TERM xterm-256color
end

if test -f "$XDG_CONFIG_HOME/.ripgreprc"
    set -gx RIPGREP_CONFIG_PATH "$XDG_CONFIG_HOME/.ripgreprc"
end

fish_add_path /home/clay/.local/bin
fish_add_path /home/clay/.cargo/bin
fish_add_path /usr/lib/qt6/bin
fish_add_path /home/clay/.pixi/bin

set -gx ZIGENV_ROOT "$HOME/.zigenv"
fish_add_path $ZIGENV_ROOT/bin
fish_add_path $ZIGENV_ROOT/shims

if type -q starship
    starship init fish | source
end

if test -d "$HOME/miniforge3"
    set -gx CONDA_CHANGEPS1 no

    # >>> conda initialize >>>
    if test -f /home/clay/miniforge3/bin/conda
        eval /home/clay/miniforge3/bin/conda "shell.fish" "hook" $argv | source
    else
        if test -f "/home/clay/miniforge3/etc/fish/conf.d/conda.fish"
            source "/home/clay/miniforge3/etc/fish/conf.d/conda.fish"
        else
            fish_add_path /home/clay/miniforge3/bin
        end
    end
    # <<< conda initialize <<<

    # >>> mamba initialize >>>
    set -gx MAMBA_EXE '/home/clay/miniforge3/condabin/mamba'
    set -gx MAMBA_ROOT_PREFIX '/home/clay/miniforge3'
    if test -f "$MAMBA_EXE"
        eval "$MAMBA_EXE" shell hook --shell fish --root-prefix "$MAMBA_ROOT_PREFIX" | source
    else
        alias mamba="$MAMBA_EXE"
    end
    # <<< mamba initialize <<<
end

set -gx NVM_DIR "$HOME/.nvm"

set -gx PYGFX_PRINT_WGSL_ON_COMPILATION_ERROR 1

source ~/dotfiles/.aliases

switch (uname -s)
    case Linux
        source ~/dotfiles/.linux_aliases
    case Darwin
        source ~/dotfiles/.mac_aliases
end

if test -f ~/dotfiles/ramona/.ramona.fish
    source ~/dotfiles/ramona/.ramona.fish
end
