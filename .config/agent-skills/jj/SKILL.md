---
name: jj
description: Plan atomic Jujutsu commits and print the commands. Use when the user asks how to split, describe, or push current jj changes.
---

Inspect `jj diff --git`, `jj status`, recent history, operation history, evolution history, and bookmarks.

Output commands and commit messages only. Never execute a mutating Jujutsu command.

Group changes into atomic commits. Order infrastructure before implementation, tests, and docs.

Use `jj split` for every commit except the final commit. Use `jj describe` and `jj new` for the final commit.

Choose a feature bookmark unless this is a personal repository or the user requests a direct push. Reuse a suitable bookmark on `@` or `@-` when present.

Put fetch and rebase before bookmark movement and push. Use imperative commit subjects.
