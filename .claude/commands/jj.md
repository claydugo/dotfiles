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

3. **For each logical commit, output:**
   ```
   ## Commit N: [description]
   Files: [list]
   Command: jj commit -i  # select files when prompted
   Message: [imperative summary]
   ```

4. **Output push sequence:**
   - **Feature branch:**
     ```bash
     jj git fetch && jj rebase -d main@origin
     jj bookmark create <descriptive-name>
     jj git push -b <descriptive-name>
     ```
   - **Direct push:**
     ```bash
     jj git fetch && jj rebase -d main@origin
     jj bookmark set main && jj git push
     ```

## Quick Reference

| Command | Use |
|---------|-----|
| `jj commit -i` | Interactive commit (primary workflow) |
| `jj split` | Finer control than commit -i |
| `jj squash` | Move changes into parent commit |
| `jj new` | Create empty change on current |
| `jj absorb` | Auto-distribute fixes to ancestors |
| `jj undo` | Revert last operation |
