---
allowed-tools: Bash(git fetch:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git merge-base:*), Bash(git rebase:*), Bash(git stash:*), Bash(git add:*), Bash(git checkout --ours:*), Bash(git checkout --theirs:*)
description: Cleanly rebase the current branch onto main
---

## Context

- Current branch: !`git branch --show-current`
- Status: !`git status --short`
- Upstream main: !`git rev-parse --abbrev-ref origin/main 2>/dev/null || echo "no origin/main — use local main"`
- Ahead of main: !`git log --oneline main..HEAD | head -20`
- Behind main: !`git log --oneline HEAD..main | head -20`

## Task

Rebase the current branch onto main, executing the commands yourself.

1. **Preflight**
   - If the current branch IS main: stop and say there's nothing to rebase.
   - If already up to date with main (behind list is empty): stop and say so.
   - `git fetch origin` if a remote exists; rebase onto `origin/main` in that case, plain `main` otherwise.

2. **Rebase**
   - Run `git rebase --autostash --update-refs <base>`.
   - If it completes cleanly, skip to step 4.

3. **Conflicts**
   - For each conflicted file: read the conflict markers, understand both sides (`git log` the relevant commits if intent is unclear), and resolve so the branch's change applies on top of the new main — don't just pick a side blindly.
   - `git add` resolved files, then `git rebase --continue`.
   - Never use `git rebase --skip` or drop a commit without asking first.
   - If the conflicts are too tangled to resolve confidently, run `git rebase --abort`, report the state is exactly as before, and explain what conflicted.

4. **Verify & report**
   - `git status` must be clean (autostash popped) and `git log --oneline main..HEAD` should show the same commits as before, now on top of main.
   - Report: how many commits were replayed, any conflicts resolved and how.
   - Do NOT push. If the branch was previously pushed, remind that `git push --force-with-lease` is now needed, but leave that to the user.
