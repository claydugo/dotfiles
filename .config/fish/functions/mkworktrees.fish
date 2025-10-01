# Create git worktrees and tmux sessions for parallel work
function mkworktrees
    set base "/home/clay/projects/temp_worktrees"

    if test (count $argv) -eq 0
        echo "Usage: mkworktrees <branch>"
        return 1
    end

    set branch $argv[1]

    # Get git repository root
    set repo_root (git -C $PWD rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "Not inside a Git repo"
        return 1
    end
    cd $repo_root; or return 1

    # Create branch if it doesn't exist
    if not git show-ref --quiet "refs/heads/$branch"
        git branch $branch; or return 1
    end

    set parent "$base/$branch"
    mkdir -p $parent; or return 1

    # Create temporary prompt file
    set temp_prompt (mktemp)
    echo "" > $temp_prompt
    echo "" >> $temp_prompt
    echo "# ========================================" >> $temp_prompt
    echo "# Enter your prompt above this line" >> $temp_prompt
    echo "# Lines starting with # will be ignored" >> $temp_prompt

    $EDITOR $temp_prompt

    # Extract prompt (remove comments and blank lines)
    set prompt (grep -v '^#' $temp_prompt | grep -v '^[[:space:]]*$')
    rm $temp_prompt

    if test -z "$prompt"
        echo "Aborted: No prompt provided"
        return 1
    end

    # Create worktrees
    for i in 1 2 3
        set dir "$parent/$branch"_"$i"
        git worktree add --detach $dir $branch
    end

    # Write prompts
    for i in 1 2 3
        echo $prompt > "$parent/$branch"_"$i/.claude_prompt"
    end

    # Create tmux session
    if not tmux has-session -t $branch 2>/dev/null
        tmux new-session -d -s $branch -c "$parent/$branch"_1 -n "$branch"_1
        tmux send-keys -t "$branch":1 'claude --dangerously-skip-permissions "$(cat .claude_prompt)"' C-m

        tmux new-window -t "$branch":2 -c "$parent/$branch"_2 -n "$branch"_2
        tmux send-keys -t "$branch":2 'codex "$(cat .claude_prompt)"' C-m

        tmux new-window -t "$branch":3 -c "$parent/$branch"_3 -n "$branch"_3
        tmux send-keys -t "$branch":3 'claude --dangerously-skip-permissions "$(cat .claude_prompt)"' C-m

        echo "tmux session \"$branch\" ready with windows $branch"_{1,2,3}
    end

    cd $parent
end
