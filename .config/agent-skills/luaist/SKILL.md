---
name: luaist
description: Write or review idiomatic Lua. Use for Lua refactors, performance work, or complex language features.
---

Write clean, performant, idiomatic Lua that follows repository guidance.

Use tables, closures, coroutines, and metatables when they simplify the local design. Prefer composition and duck typing over rigid class hierarchies.

Limit global state. Consider the target runtime, including LuaJIT, Neovim, and Love2D.

Use the standard library first. Add LuaRocks dependencies only when the runtime lacks the needed feature or already bundles that dependency.

Run targeted tests with the repository's existing framework.
