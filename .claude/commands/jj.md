# Generate jj commands for committing changes

Analyze the current uncommitted changes in this repository and help me organize them into logical, atomic commits using jj (Jujutsu VCS).

## Your task

### Step 1: Understand the codebase

**Use the Explore agent** to quickly understand:
- The project structure and module organization
- Which directories/files belong to which features
- Any existing commit conventions in recent history (`git log --oneline -20`)

This context helps group changes by feature/module boundaries.

### Step 2: Examine the diff

Run `git diff HEAD` to see all uncommitted changes. Cross-reference with the codebase structure from Step 1.

### Step 3: Identify logical groupings

Separate changes into distinct, atomic units based on:
- Module/feature boundaries discovered in Step 1
- Feature additions
- Bug fixes
- Refactoring
- Documentation updates
- Test changes (keep with their implementation when part of same feature)
- Configuration changes

### Step 4: Generate jj commands

Provide the exact jj commands I should run to:
- Split the working copy into separate commits
- Reorder commits if needed for a clean history
- Write meaningful commit messages following conventional commits format
- Push the commits to the remote

**Always end with `jj git push`** - include this command at the end of your output.

## Output format

For each logical commit, provide:

```
## Commit N: <short description>

**Files:**
- path/to/file1
- path/to/file2

**Message:**
```
<type>(<scope>): <description>

<body explaining the what and why>
```

**Commands:**
```bash
jj split -r @ ...
# ^ What this does: <explain what the command does and why we're using it here>

jj describe -m "..."
# ^ What this does: <explain what the command does>
```
```

## jj concepts to explain

When outputting commands, briefly explain these concepts as they come up:

- **Working copy = automatic commit**: Unlike git, your working directory IS a commit (called `@`). No staging needed.
- **`@` symbol**: Refers to the current working copy commit
- **Revsets**: jj's query language for selecting commits (e.g., `@-` = parent of working copy)
- **Why split works differently**: In jj, you split an existing commit rather than staging pieces
- **Immutable commits**: Explain when commits become immutable (pushed to remote)
- **Change IDs vs Commit IDs**: jj tracks changes across rewrites with stable change IDs

## jj command reference

Use these commands as needed:
- `jj split` - interactively split current change into multiple
- `jj split -r <rev>` - split a specific revision
- `jj new` - create new empty change on top of current
- `jj describe -m "message"` - set commit message
- `jj squash` - squash into parent
- `jj rebase -r <rev> -d <destination>` - reorder commits
- `jj log` - show commit graph
- `jj diff` - show current changes
- `jj bookmark set <name> -r <rev>` - move/create a bookmark (branch) to point at a revision
- `jj git push` - push commits to the remote (makes them immutable)

## Learning aids

After providing the commands, include:

1. **Git equivalent**: For each jj command used, show what you would have done in git
   ```
   jj split            → git add -p && git commit (repeated)
   jj describe         → git commit --amend (for message only)
   jj rebase -r X -d Y → git rebase -i (manual reordering)
   jj bookmark set     → git branch -f <name> (move branch pointer)
   jj git push         → git push
   ```

2. **Mental model tip**: One insight about how jj thinks differently than git

3. **What to check**: Suggest running `jj log` after to verify the result looks right

## Final step: Push

After all commits are described, always include:

```bash
jj bookmark set main -r @
# ^ What this does: Moves the 'main' bookmark to point to the current commit (@).
#   jj uses "bookmarks" instead of git's "branches". Without this, push won't know what to push.

jj git push
# ^ What this does: Pushes all new commits to the remote. This makes them immutable in jj.
```

Note: If working on a feature branch, replace `main` with the appropriate bookmark name.

## Important notes

- DO NOT run any commands - only output the commands for me to review and run manually
- Prefer smaller, focused commits over large ones
- Keep related changes together (e.g., a function and its tests)
- Order commits so dependencies come before dependents
- Use conventional commit prefixes: feat, fix, refactor, docs, test, chore, style, perf
