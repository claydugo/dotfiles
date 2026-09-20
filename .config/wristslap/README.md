# Agent rules

This configuration enables the strict preset and personal Vale styles.
The preset supplies native rules, identifier mappings, pip blocking, read guidance, and checker commands.
It keeps contextual checks and selected Vale rules at warning severity.
The directory links to `~/.config/wristslap`.

Nested fallbacks, forwarding helpers, and JSON round trips use the `review` action.
These checks permit edits and require a fix or acknowledgement before completion.

Open the terminal configuration:

```sh
wristslap configure
wristslap doctor
```

Press `/` to search rules and descriptions. Enter opens the action selector.
Use `l` to filter groups, `f` to filter actions, and `x` to show enabled entries.
Space cycles actions. Press `m` to edit feedback or `e` to edit a value.

Press `r` to add optional read guidance with warnings. Press `e` on that checker to edit its line threshold.
Use `wristslap configure --help` to inspect coverage and hook requirements.

Press `d` to inspect pending changes or `u` to restore an inherited value.
Press `s` to save or `q` to discard the changes.
Move the cursor to edit text or paste multiple lines. Paste does not submit an edit.
The editor updates the configuration in this directory.

Inspect the findings for an agent session:

```sh
wristslap findings --session SESSION --watch
```

Hook feedback supplies `SESSION`.
Press Tab to filter by status or `/` to search findings.
Press `r` to verify source previews, then `a` to enter an acknowledgement reason.
Enter verifies the finding and saves the reason. Changed source requires another review.

Blocking findings require correction. Omit `--watch` to return JSON for scripts.

Rebuild all three executables from the local project:

```sh
cargo install --path "$HOME/projects/wristslap" --locked --root "$HOME/.local"
```

Codex uses `.config/agent-hooks/codex.json`. Claude uses `.claude/settings.json`.
Both configurations call `~/.local/bin/wristslap`.
Subsequent hook calls use the rebuilt executable.
The build embeds the current strict preset.

Committing files preserves their saved comparison baselines.
Incomplete checks report diagnostics without instructions to edit code.
Statistics recording remains enabled. Inspect it with `wristslap stats --watch`.
