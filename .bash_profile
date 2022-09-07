export BASH_SILENCE_DEPRECATION_WARNING=1
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:/usr/local/sbin


source ~/.bashrc

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/clay/mambaforge/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/clay/mambaforge/etc/profile.d/conda.sh" ]; then
        . "/Users/clay/mambaforge/etc/profile.d/conda.sh"
    else
        export PATH="/Users/clay/mambaforge/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/Users/clay/mambaforge/etc/profile.d/mamba.sh" ]; then
    . "/Users/clay/mambaforge/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

