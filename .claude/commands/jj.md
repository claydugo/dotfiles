---
allowed-tools: Bash(jj diff:*), Bash(jj git init:*), Bash(jj log:*), Bash(jj status:*), Bash(jj bookmark:*), Bash(jj op log:*), Bash(jj evolog:*)
description: Generate jj commands for committing changes
---

## Context

- Diff: !`jj diff --git`
- Status: !`jj status`
- Log: !`jj log -n 10`
- Operation Log: !`jj op log -n 5`
- Evolution Log: !`jj evolog -n 5`
- Bookmarks: !`jj bookmark list`

## Rules

- **Output commands only** — never execute jj mutating commands
- **Atomic commits** — one logical change per commit
- **Dependency order** — infrastructure → implementation → tests → docs
- **Imperative mood** — "Add feature" not "Added feature"

## Workflow

1. **Determine push strategy** (do this FIRST)
   - Feature branch (default): repo uses PRs, `main` protected, needs review
   - Direct push: personal repo OR user explicitly requests

2. **Analyze changes** — group by: feature, fix, refactor, docs, config

3. **For each logical commit, output using `jj split`:**
   ```
   ## Commit N: [description]
   Files: [list]
   Command: jj split
   Message:
   [imperative summary]

   [optional body]
   ```
   (Repeat for each commit except the last)

4. **For the final commit:**
   ```
   ## Commit N: [description]
   Files: [remaining files already in @]
   Command: jj describe && jj new
   Message:
   [imperative summary]

   [optional body]
   ```
   Note: `jj new` finalizes the commit (moves it from @ to @-) so the push sequence works.

5. **Output push sequence:**
   - **Feature branch:**
     - Check the log for an existing bookmark on @ or @- (the parent)
     - If a bookmark exists, use it; otherwise create a descriptive name
     ```bash
     jj git fetch && jj rebase -d main@origin
     jj bookmark set <existing-or-new-name> -r @- --allow-backwards
     jj git push -b <existing-or-new-name>
     ```
   - **Direct push:**
     ```bash
     jj git fetch && jj rebase -d main@origin
     jj bookmark set main -r @- --allow-backwards
     jj git push
     ```

## Quick Reference

| Command | Use |
|---------|-----|
| `jj split` | Interactively split @ into multiple commits |
| `jj describe` | Set/edit commit message for @ |
| `jj new` | Create fresh empty working copy |
| `jj squash` | Move changes into parent commit |
| `jj absorb` | Auto-distribute fixes to ancestors |
| `jj undo` | Revert last operation |
