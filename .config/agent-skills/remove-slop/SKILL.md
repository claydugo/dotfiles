---
name: remove-slop
description: Remove AI-generated patterns that conflict with local style. Use when the user asks to remove slop from current changes.
---

Inspect the diff against the main branch. Remove only introduced patterns that local evidence does not justify.

Remove comments that conflict with nearby style. Remove abnormal defensive checks and broad exception handling. Remove type-system escapes and needless abstractions.

Do not treat all comments, validation, abstractions, or tests as slop. Preserve behavior and user-authored documentation.

Run targeted checks. End with a one-to-three sentence summary of the changes.
