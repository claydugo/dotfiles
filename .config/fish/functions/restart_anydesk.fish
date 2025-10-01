# Fix anydesk service restart issues
function restart_anydesk
    if not tmux has-session -t anydesk_session 2>/dev/null
        tmux new-session -d -s anydesk_session
    end
    tmux send-keys -t anydesk_session "sudo killall anydesk && sudo anydesk --service" C-m
    tmux attach -t anydesk_session
end
