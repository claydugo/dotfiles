# Agent rules

This configuration enables the strict preset and stock Vale.
The preset supplies native rules, identifier mappings, pip blocking, read guidance, and checker commands.
It keeps contextual checks and selected Vale rules at warning severity.
The directory links to `~/.config/wristslap`.

Open the terminal configuration:

```sh
wristslap configure
wristslap doctor
```

Space changes a rule's action. Press `m` to edit its message and `s` to save.
Press `r` to add optional read guidance with warnings. Press `e` on that checker to edit its line threshold.
The checker details and `wristslap configure --help` explain its coverage and hook requirements.
The editor updates the configuration in this directory.

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
