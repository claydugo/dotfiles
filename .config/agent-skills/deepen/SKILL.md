---
name: deepen
argument-hint: [prompt or task to deepen]
description: Rewrite a prompt into a deeper version of the task, as a top professional in the field would approach it
---

Task: $ARGUMENTS

If the task above is empty, use the prompt in the message that invoked this skill.

I want a deeper version of this task, not a bigger one. Before rewriting it: (1) say what a top professional in this field would do here that I'm not asking for; (2) name the rawest material they would start from instead of what has already been digested for me; (3) name the specific methods and tools they would use; (4) say what, other than you or me, would show the result is right. Then rewrite my prompt to ask for exactly that.
