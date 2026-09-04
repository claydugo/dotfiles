---
name: commitmsg
description: Draft a commit message from current Git or Jujutsu changes. Use when the user asks for a commit message without asking to commit.
---

Inspect the current status, recent log, and diff. Use Git when the repository has Git metadata. Use Jujutsu when Git commands do not describe the working copy.

Write only the commit message in a fenced code block. Never run a commit command.

Follow the repository's established commit convention. Otherwise, write an imperative subject, a blank line, and a concise body.

Keep the subject within 72 characters. Aim for 50 characters. Do not add a trailing period.

Describe behavior and intent. Use the body for motivation, constraints, and tradeoffs. Do not enumerate files or restate the diff.

Wrap the body at 72 characters. Preserve the repository's issue footer style when present.

Use active voice and present tense. Keep sentences under 20 words.

Do not use AI attribution or a co-author footer. If the diff is empty, say so and stop.
