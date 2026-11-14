---
id: script-mechanical-work
description: Turn repeated mechanical steps into scripts kept where they will be found, and keep AI for judgment
targets: claude codex generic
tags: engineering
---
## Script the mechanical work

- When a step needs no judgment (the same input always gives the same result) and it repeats or will repeat, write a script instead of doing it by hand with AI each time.
- Keep AI for the parts that need judgment; script the rest, such as gathering data, transforms, renames, builds, test runs and reports.
- Before doing such a step by hand, look for a script that already does it.
- Put a new script where it will be found: a project's own work in its `scripts/` folder, noted in its CLAUDE.md or README; a step of a skill in that skill's folder, called from its instructions; a personal tool used everywhere in `~/.local/bin`; and anything that must happen every time in a hook.
- Write project and skill scripts right away; ask first before adding to `~/.local/bin` or adding a hook.
- Give every script `--help`, a clear error message when it fails, safe repeated runs, and `--dry-run` when it changes or deletes anything.
