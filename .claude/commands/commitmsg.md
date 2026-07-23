---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git rev-parse:*), Bash(jj diff:*), Bash(jj status:*), Bash(jj log:*)
argument-hint: [extra context about the change]
description: Write a commit message for the current changes
---

## Context

- Status: !`git status --short 2>/dev/null || jj status`
- Recent log: !`git log --oneline -15 2>/dev/null || jj log -n 15`
- Diff: !`git rev-parse --git-dir >/dev/null 2>&1 && { git diff --cached --quiet 2>/dev/null && git diff || git diff --cached; } || jj diff --git`

Extra context from me: $ARGUMENTS

## Task

Write a commit message for the diff above. Output the message in a fenced code block and stop. Never run a commit command.

## Rules

- If the recent log uses Conventional Commits, follow that spec: same prefixes, same scope style. Otherwise use exactly this shape: one line succinctly summarizing the key changes, a blank line, then a body going into a bit more detail.
- Subject: imperative mood, capitalized, no trailing period, 50 characters ideal, 72 hard limit.
- Subject says what changed at the level of behavior or intent, not which files moved.
- Body covers the motivation and any detail the subject can't hold: constraints, tradeoffs, rejected alternatives. The diff already shows the what: never restate it, never enumerate files or functions.
- Wrap the body at 72 characters. Reference issues or PRs in a footer if the log shows that pattern.
- Follow ASD-STE100 Simplified Technical English: active voice, present tense, one instruction per sentence, one meaning per word, no noun clusters longer than three words. Keep sentences under 20 words.
- Banned: "This commit", "comprehensive", "enhanced", "improved", "robust", "various", "minor", bullet lists that paraphrase hunks, and any AI attribution or co-author footer.
- If the diff mixes unrelated concerns, say so in one line, then give a separate message per logical commit in dependency order.
- If the diff is empty, say so and stop.
