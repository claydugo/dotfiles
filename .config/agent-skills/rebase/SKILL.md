---
name: rebase
description: Rebase the current Git branch onto main. Use only when the user explicitly asks to execute a rebase.
---

Confirm that the current request explicitly authorizes a rebase. Do not treat a question about rebasing as permission to mutate Git state.

Inspect the branch, status, main branch, remote, merge base, and commits before changing state. Stop if the current branch is main or already current.

Fetch the remote when one exists. Rebase with `git rebase --autostash --update-refs` onto `origin/main`. Use local `main` when the remote branch does not exist.

Resolve conflicts by understanding both changes. Never select one side without inspection. Never skip or drop a commit without asking.

Abort the rebase if a conflict cannot be resolved with confidence. Report that the prior state is restored.

Verify the status and replayed commits. Report the commit count and conflict resolutions. Never push.
