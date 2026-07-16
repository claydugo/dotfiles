# Clay

Software engineer at Ramona Optics, which builds multi-camera array microscopes. Work spans computational imaging, GPU/graphics rendering, and ML for microscopy, backed by published research in the field.

Wide-ranging open-source contributor across languages and ecosystems: upstream work on core Python (CPython) and Rust projects, scientific-Python and GPU/visualization libraries, ML segmentation tooling, conda-forge packaging, and developer tooling including Neovim plugins. Assume real depth in scientific Python, GPU/WebGPU, and systems-level tooling, plus strong general competence. Pitch high: don't explain language internals, build systems, or common libraries unless asked.

Primarily Python; also writes Rust and Lua, and C. Codes in Neovim on Linux, tmux-heavy (single Neovim window per pane, no vim splits). Bleeding-edge toolchain: pixi for envs, ruff and ty as LSPs, jj alongside git.

# Git

IMPORTANT: Never run state-changing git or jj commands (add, commit, push, branch ops) unless I ask in that conversation. Read-only git is fine. After making changes, stop and report; at most mention they're ready to commit.

# Code Style

- No docstrings and no narrating comments in new code, ever. Terse one-line invariant or math comments are fine (`# var = E[x^2] - E[x]^2`). Multi-sentence explanatory blocks are slop.
- Never remove my existing comments, links, or docs unless I ask.
- No shorthand identifiers: spell out `fraction`, `rectangle`, `minimum`, `bounding_box`, `frame_count`, `world_object`. Acronyms are fine (`gpu`, `rgba`, `exif`, `nan`). Don't rename pre-existing identifiers.
- Explicit beats DRY in declarative code: write literal values at each call site instead of derived constants or negative flags ("everything except X" constants are just exclusions in disguise).
- No single-use module constants, in tests or scripts especially: inline the literal at the call site. Only name a constant when it's reused in 2+ places or genuinely needs a name.
- No `_VALID_X` allowlist tuples, and never mirror a value list that canonically lives in another module. Let the downstream consumer raise, or import the live source.
- Don't blindly copy boilerplate from similar-looking code (test trios, validator lists, config blocks). Evaluate each piece on its own merits.

# Prose Style (Docs, Commits, Comments, Wiki)

Short declarative sentences. No em-dashes as connectors: use periods, commas, colons, or parens. No `**Term** — definition` glossary bullets. No meta-summaries ("three moving parts", "the flow is") and no over-explained tails. Prefer "verify" over "sanity-check". No templated user-facing strings that interpolate invented noun phrases; reword so the varying detail disappears.

# Working with Me

- Make the minimal edit that addresses exactly what I asked. Leave surrounding code alone.
- When a task leaves room for interpretation on shared surfaces (schemas, shared dialogs, architecture), identify the specific decisions and ask instead of picking the broadest interpretation.
- When my constraints conflict, ask which one wins. Surface the technical constraint plainly with the option space instead of iterating guesses.
- Don't make non-obvious behavioral changes unasked (e.g. promoting warnings to errors). Propose them instead.
