# Generate jj commands for committing changes

Analyze uncommitted changes and organize them into logical, atomic commits using jj (Jujutsu VCS).

## Steps

1. **Initialize jj if needed**: Run `jj log -n 20` to check recent commit style. If it fails with "not a jj repo", run `jj git init --colocate` first, then retry.

2. **Understand the codebase**: Use the Explore agent to understand project structure and module boundaries.

3. **Examine changes**: Run `jj diff` to see all uncommitted changes.

4. **Identify logical groupings**: Separate into atomic units by feature, bugfix, refactor, docs, tests, or config. Keep related changes together (e.g., implementation + tests).

5. **Determine current bookmark**: Run `jj bookmark list` to identify which bookmark to push (e.g., `main`, `feature-x`).

6. **Generate commands**: Output the exact jj commands to run. DO NOT execute them.

## Output format

For each commit, provide files and commands. Only explain non-obvious commands.

Example:
```
## Commit 1: Add user validation

**Files:**
- src/validate.ts
- src/validate.test.ts

**Commands:**
```bash
jj split  # select the files above when prompted
jj describe
```

**Commit message:**
```
Add email format validation

Validates email format before submission to prevent
malformed entries in the database.
```
```

For subsequent commits: after `jj split`, the remaining changes stay in the working copy commit (`@`). Just run `jj split` again to select the next batch of files, then `jj describe`. Only use `jj new` after describing the final commit.

## Push sequence

After all commits, output (replacing `BOOKMARK` with the actual bookmark from step 4):

```bash
jj git fetch && jj rebase -d BOOKMARK@origin && jj bookmark set BOOKMARK
jj git push
```

## Reference

| Command | Purpose | Git equivalent |
|---------|---------|----------------|
| `jj split` | Interactively split current change | `git add -p && git commit` |
| `jj new` | Create empty change on top of current | `git commit --allow-empty` + working on it |
| `jj describe` | Set commit message (opens editor) | `git commit --amend` (message only) |
| `jj bookmark set X` | Move bookmark to current commit | `git branch -f X` |

**Key concept:** In jj, your working directory IS a commit (`@`). No staging—you split existing commits rather than staging pieces.

## Guidelines

- Prefer smaller, focused commits over large ones
- Order commits so dependencies come before dependents
- Write simple commit messages (no conventional commit prefixes like `feat:` or `fix:`)
- Never use `jj describe -m "..."` — always open the editor
