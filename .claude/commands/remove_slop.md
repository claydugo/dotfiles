---
description: Remove AI-generated code patterns that conflict with the local style
---

# Remove AI code slop

Check the diff against main, and remove all AI generated slop introduced in this branch.

Remove only introduced patterns that local evidence does not justify:
- Extra comments that a human wouldn't add or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to any to get around type issues
- Any other style that is inconsistent with the file

Do not treat all comments, validation, abstractions, or tests as slop. Preserve behavior and user-authored documentation.

Report at the end with only a 1-3 sentence summary of what you changed
